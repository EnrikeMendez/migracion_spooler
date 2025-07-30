SET AUTOPRINT ON
SET HEADING ON
VARIABLE X REFCURSOR
DECLARE
   v_Cur_Dat_LTL  SYS_REFCURSOR;
   v_Mensaje      VARCHAR2(4000) := ' ';
   v_Codigo_Error NUMBER(1)      := 0 ;
BEGIN 
    SC_RS_DIST.SPG_REP_REPORTES.P_DAT_PROCESOS_XPOOLER ( p_Cur_Procesos_XP => :X       --OUT SYS_REFCURSOR 
                                                       , p_Mensaje         => v_Mensaje      --OUT VARCHAR2
                                                       , p_Codigo_Error    => v_Codigo_Error --OUT NUMBER 
                                                       ) ;
    dbms_output.put_line('p_Mensaje: '||v_Mensaje||UTL_TCP.crlf||'p_Codigo_Error: '||v_Codigo_Error);
END;
/


    SC_RS_DIST.SPG_REP_REPORTES.P_DAT_PROCESOS_XPOOLER ( p_Cur_Procesos_XP OUT SYS_REFCURSOR 
                                                       , p_Mensaje         OUT VARCHAR2
                                                       , p_Codigo_Error    OUT NUMBER 
                                                       ) ;