
-- DROP FUNCTION pg_stat_monitor();
CREATE OR REPLACE FUNCTION pg_stat_monitor()
RETURNS TABLE(
               pid INT,
               state TEXT,
               application_name TEXT, 
               client_addr INET,
               usename NAME,
               datname NAME,
               backend_start timestamp with time zone,
               query_start timestamp with time zone,
               xact_start timestamp with time zone,
               time_query_run INTERVAL,
               time_sesion_run INTERVAL,
               backend_type TEXT,
               query TEXT,
               mem_usage_pct  DECIMAL(10,2),
               cpu_usage_pct   DECIMAL(10,2),
               mem_virtual_total INT,
               mem_physical_kb INT,
               cmd TEXT
		     )
SET client_min_messages='notice'
AS $$
DECLARE
  v_copy_exec TEXT := E'COPY tmp_stat_monitor from  PROGRAM $__$ %s  $__$ WITH   (FORMAT csv,HEADER false,QUOTE \'"\',ESCAPE \'"\',DELIMITER \',\');';
  v_command_shell TEXT := 'ps -C postgres -o pid=,%mem=,%cpu=,size=,rss=,cmd= --sort=-%mem | awk ''{printf "%s,%s,%s,%s,%s,\"%s\"\n", $1, $2, $3, $4,$5,$6 substr($0, index($0,$6))}''';  
  v_query_exec TEXT; 
BEGIN
		
		CREATE TEMP TABLE tmp_stat_monitor (
			pid INT,
			mem DECIMAL(10,2),
			cpu  DECIMAL(10,2),
			size INT,
			rss INT,
			cmd TEXT
		);
		
		v_query_exec := FORMAT(v_copy_exec,v_command_shell);
		
		EXECUTE  v_query_exec;
		
		return QUERY 
		SELECT 
		  coalesce(a.pid,b.pid) as pid,
		  a.state,
		  a.application_name,
		  a.client_addr,
		  a.usename,
		  a.datname,
		  a.backend_start,
		  a.query_start,
		  a.xact_start,
		  CLOCK_TIMESTAMP() - a.query_start AS time_query_run,
		  CLOCK_TIMESTAMP() - a.backend_start AS time_sesion_run,
		  a.backend_type,
		  a.query,
		  b.mem,
		  b.cpu,
	      b.size,
		  b.rss,
		  b.cmd		  
		FROM tmp_stat_monitor as  b 
		LEFT JOIN pg_stat_activity as a on a.pid = b.pid;
		
		DROP TABLE IF EXISTS tmp_stat_monitor;
END;
$$ LANGUAGE plpgsql;


/*
select * from FROM pg_stat_monitor();

SELECT 
		pid
		,state
		,client_addr
		,usename
		--,datname
		,time_sesion_run
		,time_query_run
		,backend_type		
		,mem_usage_pct
		,cpu_usage_pct
		,mem_physical_kb
		--,query
		--,cmd
FROM pg_stat_monitor() 
--WHERE backend_type = 'client backend'
order by mem_physical_kb desc ;
 
 

🧠 pid: ID del proceso
📈 %mem: Porcentaje de memoria usada
🔥 %cpu: Porcentaje de CPU utilizada
💾 rss: mide el consumo real de RAM del proceso.
🧾 cmd: Comando exacto que se ejecutó

 */
