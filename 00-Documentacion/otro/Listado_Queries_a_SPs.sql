--SC_RS_DIST.SPG_REP_REPORTES.P_FECHA_REP_AUTO
SELECT	SC_RS_DIST.SPG_REP_UTL.F_OBTEN_FECHA_REP_AUTOMATICOS({p_Frecuencia},SYSDATE,SYSDATE,1) AS FECHAS
FROM	DUAL;

--SC_RS_DIST.SPG_REP_REPORTES.P_NUM_PARAMS
SELECT	REPORT.NUM_OF_PARAM
FROM	REP_REPORTE REPORT
	inner join	REP_DETALLE_REPORTE REP
		on	REPORT.ID_REP	=	REP.ID_REP
WHERE	REP.ID_CRON	=	{0};

SELECT	REPORT.CANTIDAD_PARAMETROS
FROM	SC_RS_DIST.TC_REP_REPORTES REPORT
	INNER JOIN	SC_RS_DIST.TB_REP_DETALLE_REPORTE REP
		ON	REPORT.ID_REPORTE	=	REP.ID_REPORTE
WHERE	REP.ID_CRON	=	{p_Id_Cron};

--SC_RS_DIST.SPG_REP_REPORTES.P_LIMPIA_CHRON_PROGRESO
update	rep_chron
	set	in_progress	=	0
where	id_rapport	=	'" + pargral[9, 1] + "';

UPDATE	SC_RS_DIST.TB_REP_CHRON
	SET	EN_EJECUCION	=	0
WHERE	ID_CRON	=	{p_Id_Cron};

--SC_RS_DIST.SPG_REP_REPORTES.P_ELIMINA_CHRON_PROCESO
/*
delete
from	rep_detalle_reporte
where	id_cron	=	'" + pargral[9, 1] + "';
*/
update	rep_detalle_reporte
set status = 0
where	id_cron	=	'" + pargral[9, 1] + "';

UPDATE	SC_RS_DIST.TB_REP_DETALLE_REPORTE
	SET	STATUS	=	0
WHERE	ID_CRON	=	{p_Id_Cron};

--SC_RS_DIST.SPG_REP_REPORTES.P_LIBERA_MSJ	*******
update	rep_reporte
	set	 TEMP_MENSAJE	=	NULL
		,TEMP_MENSAJE_FECHA	=	NULL
 where id_rep= '" + pargral[9, 1] + "';

--SC_RS_DIST.SPG_REP_REPORTES.P_REGISTRA_ARCHIVO
insert into	rep_archivos (id_rep, carpeta, nombre, date_created, DEST_MAIL, PARAMS, days_deleted, subcarpeta, tipo_reporte, HASH_MD5, FECHA_INICIO, FECHA_FIN)
	values	('" + id_rep.ToString() + "', '" + pargral[1, 1] + "', '" + html[0, i] + "', sysdate, '" + pargral[0, 1] + "'
		if (pargral[8, 1] == "")
			,'" + pargral[2, 1].Replace("'", "''") + "', " + pargral[3, 1] + ", '" + nvl(pargral[4, 1]) + "', '" + nvl(pargral[5, 1]) + "', '" + html[3, i] + "', to_date('" + pargral[6, 1] + "', 'mm/dd/yyyy'), to_date('" + pargral[7, 1] + "', 'mm/dd/yyyy'));
		else
			,'" + pargral[2, 1].Replace("'", "''") + "', " + pargral[3, 1] + ", '" + nvl(pargral[4, 1]) + "', '" + nvl(pargral[5, 1]) + "', '" + html[3, i] + "', to_date('" + pargral[8, 1] + "', 'mm/dd/yyyy'), to_date('" + pargral[6, 1] + "', 'mm/dd/yyyy'));

INSERT INTO	SC_RS_DIST.TB_REP_ARCHIVOS (ID_CRON, CARPETA, SUBCARPETA, NOMBRE_ARCHIVO, RESPALDO, BORRADO, PARAMETROS_USADOS, DIAS_BORRADO, HASH_MD5, FECHA_INICIO, FECHA_FIN, DATE_CREATED, CREATED_BY)
	VALUES	({p_Id_Cron}, {p_Id_Reporte}, '{p_carpeta}', '{p_subcarpeta}', '{p_nombre_archivo}', {p_respaldo}, {p_borrado}, '{p_parametros_utilizados}', {p_dias_borrado}, '{p_hash}', {p_fecha_inicio}, {p_fecha_fin}, SYSDATE, {p_usuario});