#!/usr/bin/env python3
"""Enable Bedrock provider data sharing for Claude Fable 5.

provider_data_share allows prompts and completions for Claude Fable 5 /
Mythos-class models to be shared with Anthropic and retained up to 30 days for
trust and safety. This is required by AWS Bedrock for Claude Fable 5.

Source:
https://docs.aws.amazon.com/bedrock/latest/userguide/data-retention.html
"""

from __future__ import annotations

import datetime as dt
import hashlib
import hmac
import json
import os
import shutil
import subprocess
import sys
import urllib.error
import urllib.request
from dataclasses import dataclass
from typing import Any
from urllib.parse import urlsplit


SERVICE = "bedrock"
RETENTION_MODE = "provider_data_share"


@dataclass(frozen=True)
class Credentials:
    access_key: str
    secret_key: str
    token: str | None = None


def load_botocore_credentials(profile: str) -> Credentials | None:
    try:
        import botocore.session
    except ImportError:
        return None

    session = botocore.session.get_session()
    session.set_config_variable("profile", profile)
    resolved = session.get_credentials()
    if resolved is None:
        return None

    frozen = resolved.get_frozen_credentials()
    return Credentials(
        access_key=frozen.access_key,
        secret_key=frozen.secret_key,
        token=frozen.token,
    )


def load_aws_cli_credentials(profile: str) -> Credentials:
    if shutil.which("aws") is None:
        raise RuntimeError(
            "Could not import botocore and aws CLI is not available. "
            "Install botocore or aws CLI v2."
        )

    proc = subprocess.run(
        [
            "aws",
            "configure",
            "export-credentials",
            "--profile",
            profile,
            "--format",
            "process",
        ],
        check=False,
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        message = proc.stderr.strip() or proc.stdout.strip()
        raise RuntimeError(f"aws configure export-credentials failed: {message}")

    data = json.loads(proc.stdout)
    return Credentials(
        access_key=data["AccessKeyId"],
        secret_key=data["SecretAccessKey"],
        token=data.get("SessionToken"),
    )


def load_credentials(profile: str) -> Credentials:
    credentials = load_botocore_credentials(profile)
    if credentials is not None:
        return credentials
    return load_aws_cli_credentials(profile)


def sha256_hex(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def sign(key: bytes, value: str) -> bytes:
    return hmac.new(key, value.encode("utf-8"), hashlib.sha256).digest()


def signing_key(secret_key: str, date_stamp: str, region: str) -> bytes:
    k_date = sign(("AWS4" + secret_key).encode("utf-8"), date_stamp)
    k_region = sign(k_date, region)
    k_service = sign(k_region, SERVICE)
    return sign(k_service, "aws4_request")


def signed_headers(
    method: str,
    url: str,
    body: bytes,
    region: str,
    credentials: Credentials,
) -> dict[str, str]:
    now = dt.datetime.now(dt.timezone.utc)
    amz_date = now.strftime("%Y%m%dT%H%M%SZ")
    date_stamp = now.strftime("%Y%m%d")
    parsed = urlsplit(url)
    payload_hash = sha256_hex(body)

    headers = {
        "content-type": "application/json",
        "host": parsed.netloc,
        "x-amz-content-sha256": payload_hash,
        "x-amz-date": amz_date,
    }
    if credentials.token:
        headers["x-amz-security-token"] = credentials.token

    signed_header_names = sorted(headers)
    canonical_headers = "".join(
        f"{name}:{headers[name]}\n" for name in signed_header_names
    )
    canonical_request = "\n".join(
        [
            method,
            parsed.path or "/",
            parsed.query,
            canonical_headers,
            ";".join(signed_header_names),
            payload_hash,
        ]
    )
    credential_scope = f"{date_stamp}/{region}/{SERVICE}/aws4_request"
    string_to_sign = "\n".join(
        [
            "AWS4-HMAC-SHA256",
            amz_date,
            credential_scope,
            sha256_hex(canonical_request.encode("utf-8")),
        ]
    )
    signature = hmac.new(
        signing_key(credentials.secret_key, date_stamp, region),
        string_to_sign.encode("utf-8"),
        hashlib.sha256,
    ).hexdigest()
    headers["authorization"] = (
        "AWS4-HMAC-SHA256 "
        f"Credential={credentials.access_key}/{credential_scope}, "
        f"SignedHeaders={';'.join(signed_header_names)}, "
        f"Signature={signature}"
    )
    return headers


def request(
    method: str,
    url: str,
    region: str,
    credentials: Credentials,
    payload: dict[str, Any] | None = None,
) -> dict[str, Any]:
    body = b"" if payload is None else json.dumps(payload).encode("utf-8")
    headers = signed_headers(method, url, body, region, credentials)
    req = urllib.request.Request(url, data=body or None, headers=headers, method=method)

    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            response_body = response.read()
    except urllib.error.HTTPError as exc:
        error_body = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"{method} {url} failed with HTTP {exc.code}: {error_body}")

    if not response_body:
        return {}
    return json.loads(response_body)


def print_json(label: str, data: dict[str, Any]) -> None:
    print(label)
    print(json.dumps(data, indent=2, sort_keys=True))


def main() -> int:
    profile = os.environ.get("AWS_PROFILE", "default")
    region = os.environ.get("AWS_REGION", "us-east-1")
    url = f"https://bedrock.{region}.amazonaws.com/data-retention"
    credentials = load_credentials(profile)

    before = request("GET", url, region, credentials)
    print_json("Current Bedrock account data retention:", before)

    updated = request("PUT", url, region, credentials, {"mode": RETENTION_MODE})
    print_json("Updated Bedrock account data retention:", updated)

    after = request("GET", url, region, credentials)
    print_json("Confirmed Bedrock account data retention:", after)

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"error: {exc}", file=sys.stderr)
        raise SystemExit(1)
