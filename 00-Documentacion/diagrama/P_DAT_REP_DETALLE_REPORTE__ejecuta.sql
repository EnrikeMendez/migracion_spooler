/*  *   *   REP_DETALLE_REPORTE    *   *   */
SET AUTOPRINT ON
SET HEADING ON
VARIABLE X REFCURSOR
DECLARE
   v_Mensaje          VARCHAR2(4000);
   v_Codigo_Error     NUMBER := 0;
   v_id_reporte       NUMBER := 1;
BEGIN
    SC_RS_DIST.SPG_REP_REPORTES.P_DAT_DETALLE_REPORTE ( p_Id_Cron      => 1              -- IN NUMBER
                                                      , p_Cur_DET_REP  => :X             --OUT SYS_REFCURSOR 
                                                      , p_Mensaje      => v_Mensaje      --OUT VARCHAR2
                                                      , p_Codigo_Error => v_Codigo_Error --OUT NUMBER 
                                                      ) ;
   DBMS_OUTPUT.PUT_LINE('p_Mensaje: '||v_Mensaje||UTL_TCP.crlf||'p_Codigo_Error: '||v_Codigo_Error||UTL_TCP.crlf);
END;