# Langfuse setup and management
langfuse-setup:
    @echo "Summoning Langfuse from the ethereal plane..."
    docker network create langfuse-network || true
    docker volume create lf_postgres_data
    docker run -d \
      --name postgres-langfuse \
      --network langfuse-network \
      -e POSTGRES_USER=langfuse_user \
      -e POSTGRES_PASSWORD=not_secure_password \
      -e POSTGRES_DB=langfuse_db \
      -p 5438:5432 \
      -v lf_postgres_data:/var/lib/postgresql/data \
      docker.io/postgres:15-alpine
    docker run -d \
      --name langfuse \
      --network langfuse-network \
      -e DATABASE_URL=postgresql://langfuse_user:not_secure_password@postgres-langfuse/langfuse_db \
      -e NEXTAUTH_URL=http://localhost:3008 \
      -e NEXTAUTH_SECRET=definitely_not_a_secret_key \
      -e SALT=not_so_salty_secret \
      -e ENCRYPTION_KEY=e0cfac38617698e752615db8522c0bcd4fedc08087e9bc252d4badd9d877bb29 \
      -p 3008:3000 \
      langfuse/langfuse:latest

langfuse-start:
    @echo "Awakening the Langfuse spirits..."
    docker start postgres-langfuse
    docker start langfuse

langfuse-proxy:
    @echo "Proxying Langfuse..."
    uv tool install litellm

langfuse-stop:
    @echo "Putting Langfuse to rest..."
    docker stop langfuse
    docker stop postgres-langfuse

langfuse-status:
    @echo "Divining the status of Langfuse:"
    docker ps -a | grep 'langfuse\|postgres-langfuse'

langfuse-teardown:
    @echo "Dismantling the Langfuse setup..."
    docker stop langfuse postgres-langfuse || true
    docker rm langfuse postgres-langfuse || true
    docker volume rm lf_postgres_data || true

langfuse-reset: langfuse-teardown langfuse-setup
