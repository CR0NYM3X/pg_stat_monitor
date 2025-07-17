# pg_stat_monitor 📊

`pg_stat_monitor()` es una función avanzada para PostgreSQL que fusiona estadísticas internas de sesión (`pg_stat_activity`) con métricas de procesos extraídas directamente del sistema operativo. Permite visualizar en tiempo real el uso de recursos y comportamiento de cada proceso backend del servidor.

## 🛠️ Requisitos

- PostgreSQL ≥ 10
- Acceso a comandos `ps, awk` desde el sistema operativo
- Permisos suficientes para ejecutar funciones con acceso externo


## 🚀 Características

- Consulta duración de sesiones y queries activas
- Monitorea uso de CPU (%) y memoria (%) por proceso
- Mide memoria virtual total y memoria física (RAM) real
- Muestra la IP del cliente y el tipo de backend conectado
- Accede al comando exacto ejecutado por cada proceso

## 📦 Ejemplo de uso

```sql
SELECT 
  pid,
  state,
  client_addr,
  usename,
  time_sesion_run,
  time_query_run,
  backend_type,
  mem_usage_pct,
  cpu_usage_pct,
  mem_physical_kb
FROM pg_stat_monitor()
ORDER BY mem_physical_kb DESC;
```


## 🧠 Columnas destacadas

| Campo             | Descripción                                 |
|------------------|---------------------------------------------|
| `pid`            | ID del proceso backend                      |
| `state`          | Estado actual de la sesión                  |
| `client_addr`    | Dirección IP del cliente conectado          |
| `usename`        | Usuario de la sesión                        |
| `time_sesion_run`| Duración desde el inicio de la sesión       |
| `time_query_run` | Duración de la query actual en ejecución    |
| `mem_usage_pct`  | Porcentaje de memoria usada por el proceso  |
| `cpu_usage_pct`  | Porcentaje de CPU usada                     |
| `mem_physical_kb`| Memoria física (RAM) usada en KB (`rss`)    |
| `cmd`            | Comando ejecutado (opcional para debug)     |

