# Gemini CLI Configuration

Este directorio contiene la configuración base para Gemini CLI.

## Instalación

```bash
just install-gemini
```

## Extensiones Recomendadas

### Chrome DevTools MCP

```bash
gemini mcp add chrome-devtools -- npx chrome-devtools-mcp@latest --browser-url=http://127.0.0.1:9222
```

### Gemini Plan Commands

Comandos adicionales para planificación:

```bash
gemini extensions install https://github.com/ddobrin/gemini-plan-commands
```

Comandos disponibles:
- `/plan:new` - Generar nuevo plan
- `/plan:impl` - Implementar plan
- `/plan:refine` - Refinar plan existente
- `/review:review-code` - Code review

## Uso con Chrome Debugging

1. Inicia Chrome: `chrome-debug`
2. Permite conexiones en `chrome://inspect/#remote-debugging`
3. Usa Gemini CLI normalmente

## Variables de Entorno

Asegúrate de tener configurado:

```fish
set -gx GEMINI_API_KEY "tu-api-key"
```

O en tu archivo `.env` para usar con `just install-secrets`.
