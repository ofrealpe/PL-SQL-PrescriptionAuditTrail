DECLARE 
    -- Define variables for start and end dates, prescription number, and board status
    FEC_INI DATE := :pdt_fec_ini;
    FEC_FIN DATE := :pdt_fec_fin;
    PRESCRIPCION VARCHAR2(22);
    ESTADO_JUNTA VARCHAR2(100);

    -- Cursor to select prescription codes based on creation date and specific service code
    CURSOR cu_datos IS
    SELECT COD_PRESCRIPCION
    FROM ips.ips_solicitud_servicio serv, ips_solicitud_no_pos sol
    WHERE serv.cod_solicitud_serv = sol.cod_solicitud_serv
    AND serv.fec_creacion >= FEC_INI
    AND serv.fec_creacion < FEC_FIN + 1
    AND sol.cod_solicitud_serv IN (2310436); 

BEGIN
    -- Loop through each record fetched by the cursor
    FOR x IN cu_datos LOOP
        -- Retrieve the prescription number
        SELECT pres.NOPRESCRIPCION
        INTO PRESCRIPCION
        FROM ips_prescripcion pres
        WHERE pres.NOPRESCRIPCION = x.cod_prescripcion;

        -- Determine the status of the professional board for complementary prescriptions
        SELECT DECODE (a1.valor,
                       	1, 'Does not require professional board',
			2, 'Requires professional board and pending evaluation',
			3, 'Evaluated by the professional board and approved',
			4, 'Evaluated by the professional board and not approved'ESTADO_JUNTA
        INTO ESTADO_JUNTA       
        FROM ips_complementarios_pres a,
        TABLE (a.deta_complementarios) a1
        WHERE a.NOPRESCRIPCION = x.cod_prescripcion
        AND a1.clave IN ('EstJM');

        -- Determine the status of the professional board for nutritional prescriptions
        SELECT DECODE (b1.valor,
                       	1, 'Does not require professional board',
			2, 'Requires professional board and pending evaluation',
			3, 'Evaluated by the professional board and approved',
			4, 'Evaluated by the professional board and not approved' ESTADO_JUNTA
        INTO ESTADO_JUNTA       
        FROM ips_nutricionales_presc b,
        TABLE (b.deta_nutricionales) b1
        WHERE b.NOPRESCRIPCION = x.cod_prescripcion
        AND b1.clave IN ('EstJM');                  

        -- Determine the status of the professional board for medication prescriptions
        SELECT DECODE (c1.valor,
                       	1, 'Does not require professional board',
			2, 'Requires professional board and pending evaluation',
			3, 'Evaluated by the professional board and approved',
			4, 'Evaluated by the professional board and not approved') ESTADO_JUNTA
        INTO ESTADO_JUNTA       
        FROM ips_prescripcion_medi c,
        TABLE (c.deta_medicamento) c1
        WHERE c.NOPRESCRIPCION = x.cod_prescripcion
        AND c1.clave IN ('EstJM');                                         

        -- Output the prescription number and board status
        DBMS_OUTPUT.PUT_LINE(PRESCRIPCION || ' - ' || ESTADO_JUNTA);
    END LOOP;
END;
