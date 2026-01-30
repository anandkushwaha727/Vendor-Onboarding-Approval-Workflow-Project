CLASS lhc_vendor DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.



    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR vendor RESULT result.

    METHODS ApproveByFinance FOR MODIFY
      IMPORTING keys FOR ACTION vendor~ApproveByFinance RESULT result.

    METHODS ApproveByManager FOR MODIFY
      IMPORTING keys FOR ACTION vendor~ApproveByManager RESULT result.

    METHODS Reject FOR MODIFY
      IMPORTING keys FOR ACTION vendor~Reject RESULT result.

    METHODS Submit FOR MODIFY
      IMPORTING keys FOR ACTION vendor~Submit RESULT result.

    METHODS set_initial_status FOR DETERMINE ON savE
      IMPORTING keys FOR vendor~set_initial_status.







    METHODS validate_gstin FOR VALIDATE ON SAVE

      IMPORTING keys FOR vendor~validate_gstin.

    METHODS validate_pan FOR VALIDATE ON SAVE
      IMPORTING keys FOR vendor~validate_pan.

ENDCLASS.

CLASS lhc_vendor IMPLEMENTATION.

  METHOD get_instance_authorizations.



  READ ENTITIES OF zvendor_root
    IN LOCAL MODE
    ENTITY vendor
    FIELDS ( status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_vendor).

  LOOP AT lt_vendor INTO DATA(ls_vendor).

    DATA ls_auth LIKE LINE OF result.
    ls_auth-%tky = ls_vendor-%tky.

    IF ls_vendor-status = '06'.
      ls_auth-%update = if_abap_behv=>auth-allowed.
      ls_auth-%delete = if_abap_behv=>auth-allowed.
    ELSE.
      ls_auth-%update = if_abap_behv=>auth-unauthorized.
      ls_auth-%delete = if_abap_behv=>auth-unauthorized.
    ENDIF.

    APPEND ls_auth TO result.

  ENDLOOP.




  ENDMETHOD.
METHOD ApproveByManager.

  DATA: lv_tstmp   TYPE timestampl,
        lv_utclong TYPE utclong.

  GET TIME STAMP FIELD lv_tstmp.

  cl_abap_tstmp=>tstmp2utclong(
    EXPORTING
      timestamp = lv_tstmp
    RECEIVING
      utclong   = lv_utclong
  ).

  READ ENTITIES OF zvendor_root
    IN LOCAL MODE
    ENTITY vendor
    FIELDS ( Status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_approve).

  LOOP AT lt_approve INTO DATA(ls_approve).

    IF ls_approve-Status <> '01'.
      APPEND VALUE #(
        %tky = ls_approve-%tky
        %msg = new_message(
                 id       = 'ZVENDOR'
                 number   = '008'
                 severity = if_abap_behv_message=>severity-error
                 v1       = 'Vendor must be submitted before manager approval'
               )
      ) TO reported-vendor.
      CONTINUE.
    ENDIF.


    MODIFY ENTITIES OF zvendor_root
      IN LOCAL MODE
      ENTITY vendor
      UPDATE FIELDS ( Status LastActionby LastActionat )
      WITH VALUE #( (
        %tky         = ls_approve-%tky
        Status       = '02'        " Manager Approved
        LastActionby = sy-uname
        LastActionat = lv_utclong
      ) ).

    APPEND VALUE #( %tky = ls_approve-%tky ) TO result.

  ENDLOOP.

ENDMETHOD.

 METHOD ApproveByFinance.

  DATA: lv_tstmp   TYPE timestampl,
        lv_utclong TYPE utclong.

  GET TIME STAMP FIELD lv_tstmp.

  cl_abap_tstmp=>tstmp2utclong(
    EXPORTING
      timestamp = lv_tstmp
    RECEIVING
      utclong   = lv_utclong
  ).

  READ ENTITIES OF zvendor_root
    IN LOCAL MODE
    ENTITY vendor
    FIELDS ( Status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_finance).

  LOOP AT lt_finance INTO DATA(ls_finance).

    IF ls_finance-Status <> '02'.
      APPEND VALUE #(
        %tky = ls_finance-%tky
        %msg = new_message(
                 id       = 'ZVENDOR'
                 number   = '011'
                 severity = if_abap_behv_message=>severity-error
                 v1       = 'Manager approval required before finance approval'
               )
      ) TO reported-vendor.
      CONTINUE.
    ENDIF.




    MODIFY ENTITIES OF zvendor_root
      IN LOCAL MODE
      ENTITY vendor
      UPDATE FIELDS ( Status LastActionby LastActionat )
      WITH VALUE #( (
        %tky         = ls_finance-%tky
        Status       = '03'        " Finance Approved
        LastActionby = sy-uname
        LastActionat = lv_utclong
      ) ).

    APPEND VALUE #( %tky = ls_finance-%tky ) TO result.

  ENDLOOP.

ENDMETHOD.
 METHOD Reject.

  DATA: lv_tstmp   TYPE timestampl,
        lv_utclong TYPE utclong.

  " Get current UTC timestamp
  GET TIME STAMP FIELD lv_tstmp.

  cl_abap_tstmp=>tstmp2utclong(
    EXPORTING
      timestamp = lv_tstmp
    RECEIVING
      utclong   = lv_utclong
  ).

  READ ENTITIES OF zvendor_root
    IN LOCAL MODE
    ENTITY vendor
    FIELDS ( Status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_reject).

  LOOP AT lt_reject INTO DATA(ls_reject).

    " Reject allowed only from Submitted / Manager Approved / Finance Approved
    IF ls_reject-Status <> '01'
       AND ls_reject-Status <> '02'
       AND ls_reject-Status <> '03'.

      APPEND VALUE #(
        %tky = ls_reject-%tky
        %msg = new_message(
                 id       = 'ZVENDOR'
                 number   = '012'
                 severity = if_abap_behv_message=>severity-error
                 v1       = 'Vendor cannot be rejected in current status'
               )
      ) TO reported-vendor.

      CONTINUE.
    ENDIF.

    " Reject vendor
    MODIFY ENTITIES OF zvendor_root
      IN LOCAL MODE
      ENTITY vendor
      UPDATE FIELDS ( Status LastActionby LastActionat )
      WITH VALUE #( (
        %tky         = ls_reject-%tky
        Status       = '05'        " Rejected
        LastActionby = sy-uname
        LastActionat = lv_utclong
      ) ).

    APPEND VALUE #( %tky = ls_reject-%tky ) TO result.

  ENDLOOP.

ENDMETHOD.


METHOD submit.

  DATA: lv_tstmp   TYPE timestampl,
        lv_utclong TYPE utclong.

  " Get current UTC timestamp safely
  GET TIME STAMP FIELD lv_tstmp.

  cl_abap_tstmp=>tstmp2utclong(
    EXPORTING
      timestamp = lv_tstmp
    RECEIVING
      utclong   = lv_utclong
  ).

  " Read current vendor instances
  READ ENTITIES OF zvendor_root
    IN LOCAL MODE
    ENTITY vendor
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_vendor).

  LOOP AT lt_vendor INTO DATA(ls_vendor).

    " Allow submit only for Draft vendors
    IF ls_vendor-Status <> '06'.
      APPEND VALUE #(
        %tky = ls_vendor-%tky
        %msg = new_message(
                 id       = 'ZVENDOR'
                 number   = '001'
                 severity = if_abap_behv_message=>severity-error
                 v1       = 'Only Draft vendors can be submitted'
               )
      ) TO reported-vendor.
      CONTINUE.
    ENDIF.
data ls_log tYPE zvendor01_log.
CLEAR ls_log.
    ls_log-client      = sy-mandt.
    ls_log-vid         = ls_vendor-vid.
    ls_log-action      = 'SUBMIT'.
    ls_log-user_id     = sy-uname.
    ls_log-timestap    = lv_utclong.
    ls_log-description = 'Vendor submitted for approval'.

    TRY.
        ls_log-log_id = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        APPEND VALUE #(
          %tky = ls_vendor-%tky
          %msg = new_message(
                   id       = 'ZVENDOR'
                   number   = '099'
                   severity = if_abap_behv_message=>severity-error
                   v1       = 'Failed to create audit log'
                 )
        ) TO reported-vendor.
        CONTINUE.
    ENDTRY.

    " Append to shared buffer (SAVE phase will persist)
    APPEND ls_log TO zcl_bp_vendor_root=>gt_log.


    " Update vendor status and audit fields
    MODIFY ENTITIES OF zvendor_root
      IN LOCAL MODE
      ENTITY vendor
      UPDATE FIELDS ( Status LastActionby LastActionat )
      WITH VALUE #( (
        %tky         = ls_vendor-%tky
        Status       = '01'        " SUBMITTED
        LastActionby = sy-uname
        LastActionat = lv_utclong
      ) ).




    " Return modified instance
    APPEND VALUE #( %tky = ls_vendor-%tky ) TO result.

  ENDLOOP.

ENDMETHOD.



METHOD set_initial_status.

  READ ENTITIES OF zvendor_root
    IN LOCAL MODE
    ENTITY vendor
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_vendor).

  LOOP AT lt_vendor INTO DATA(ls_vendor).

    IF ls_vendor-Status IS INITIAL.

      MODIFY ENTITIES OF zvendor_root
        IN LOCAL MODE
        ENTITY vendor
        UPDATE FIELDS ( Status )
        WITH VALUE #( (
          %tky   = ls_vendor-%tky
          Status = '06'
        ) ).

    ENDIF.

  ENDLOOP.

ENDMETHOD.




  METHOD validate_gstin.
  Read entiTIES OF zvendor_root
  in locaL MODE
  entitY vendor
  fieldS ( GstinNumber )
  with correSPONDING #( keys )
  result data(lt_gstin).

  loop at lt_gstin into data(ls_gstin).
  if ls_gstin-GstinNumber is inITIAL.
  appeND VALUE #(
  %tky = ls_gstin-%tky
  %msg = new_message(
   id       = 'ZVENDOR'
             number   = '002'
             severity = if_abap_behv_message=>severity-error
             v1       = 'GSTIN must be entered'

   )
  ) to reported-vendor.
  endIF.
  if strlen( |{ ls_gstin-gstinnumber }| ) <> 15.
   appeND VALUE #(
  %tky = ls_gstin-%tky
  %msg = new_message(
   id       = 'ZVENDOR'
             number   = '003'
             severity = if_abap_behv_message=>severity-error
             v1       = 'GSTIN must be Exactly 15 Characters'

   )
  ) to reported-vendor.
  endIF.

  eNDLOOP.
  ENDMETHOD.

  METHOD validate_pan.
  Read entiTIES OF zvendor_root
  in locaL MODE
  entitY vendor
  fieldS ( PanNumber )
  with correSPONDING #( keys )
  result data(lt_pan).

  loop at lt_pan into data(ls_pan).
  if ls_pan-PanNumber is inITIAL.
  appeND VALUE #(
  %tky = ls_pan-%tky
  %msg = new_message(
   id       = 'ZVENDOR'
             number   = '004'
             severity = if_abap_behv_message=>severity-error
             v1       = 'PanNumber  must be entered'

   )
  ) to reported-vendor.
  endIF.
  if  strlen( |{ ls_pan-PanNumber }| ) <> 10..
   appeND VALUE #(
  %tky = ls_pan-%tky
  %msg = new_message(
   id       = 'ZVENDOR'
             number   = '006'
             severity = if_abap_behv_message=>severity-error
             v1       = 'PAN Number  must be Exactly 10 Characters'

   )
  ) to reported-vendor.
  endIF.

  eNDLOOP.
  ENDMETHOD.

ENDCLASS.
