function setproxy
    set -gx http_proxy http://100.92.54.44:9090
    set -gx https_proxy http://100.92.54.44:9090
    set -gx no_proxy localhost,127.0.0.1,::1
    set -gx HTTP_PROXY $http_proxy
    set -gx HTTPS_PROXY $https_proxy
    set -gx REQUESTS_CA_BUNDLE /etc/pki/tls/certs/ca-bundle.crt
    echo "Proxy enabled for this session."
end

function unsetproxy
    set -e http_proxy
    set -e https_proxy
    set -e no_proxy
    set -e HTTP_PROXY
    set -e HTTPS_PROXY
    set -e REQUESTS_CA_BUNDLE
    echo "Proxy disabled for this session."
end
