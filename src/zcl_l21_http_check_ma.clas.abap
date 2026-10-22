CLASS zcl_l21_http_check_MA DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_l21_http_check_MA IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    TRY.
        out->write( '1. Finding the S/4HANA destination...' ).

        "The destination contains the configured host and credentials.
        DATA(lo_destination) =
          cl_http_destination_provider=>create_by_comm_arrangement(
            comm_scenario = 'ZBTP_TRIAL_SAP_COM_0309'
          ).

        DATA(lo_client) =
          cl_web_http_client_manager=>create_by_http_destination(
            i_destination = lo_destination
          ).

        "Keep the OData service path already in the destination.
        lo_client->enable_path_prefix( ).

        DATA(lo_request) = lo_client->get_http_request( ).

        "Request the Product entity set and only one record.
        lo_request->set_uri_path(
          i_uri_path = '/A_ClfnProduct'
        ).
        lo_request->set_query(
          query = '$top=1&$format=json'
        ).

        out->write( '2. Sending HTTP GET...' ).
        DATA(lo_response) = lo_client->execute(
          i_method = if_web_http_client=>get
        ).

        DATA(ls_status) = lo_response->get_status( ).
        out->write( |HTTP status: { ls_status-code }| ).

        DATA(lv_body) = lo_response->get_text( ).

        IF ls_status-code = 200.
          out->write( 'PASS: The remote API responded.' ).
        ELSE.
          out->write( 'CHECK: The API did not return HTTP 200.' ).
        ENDIF.

        "Limit the console output: the Product API has many fields.
        IF strlen( lv_body ) > 600.
          lv_body = substring(
            val = lv_body
            off = 0
            len = 600
          ).
        ENDIF.

        out->write( 'Response preview (may be truncated):' ).
        out->write( lv_body ).

      CATCH cx_root INTO DATA(lx_error).
        out->write( 'ERROR during the HTTP test:' ).
        out->write( lx_error->get_text( ) ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
