CLASS zcl_l21_filter_ma DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_l21_filter_ma IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA lt_products TYPE TABLE OF
      zsc_l21_prod_ma=>tys_a_clfn_product_type.

    "A range represents the condition Product = 'A001'.
    DATA lt_product_range TYPE if_rap_query_filter=>tt_range_option.
    lt_product_range = VALUE #(
      ( sign = 'I' option = 'EQ' low = 'B003' )
    ).

    TRY.
        DATA(lo_destination) =
          cl_http_destination_provider=>create_by_comm_arrangement(
            comm_scenario = 'ZBTP_TRIAL_SAP_COM_0309'
          ).

        DATA(lo_http_client) =
          cl_web_http_client_manager=>create_by_http_destination(
            i_destination = lo_destination
          ).

        DATA(lo_proxy) =
          /iwbep/cl_cp_factory_remote=>create_v2_remote_proxy(
            is_proxy_model_key = VALUE #(
              repository_id       = 'DEFAULT'
              proxy_model_id      = 'ZSC_L21_PROD_MA'
              proxy_model_version = '0001'
            )
            io_http_client = lo_http_client
            iv_relative_service_root = ''
          ).

        DATA(lo_request) =
          lo_proxy->create_resource_for_entity_set(
            'A_CLFN_PRODUCT'
          )->create_request_for_read( ).

        "Build a remote OData filter from the range.
        DATA(lo_filter) =
          lo_request->create_filter_factory( )->create_by_range(
            iv_property_path = 'PRODUCT'
            it_range         = lt_product_range
          ).

        lo_request->set_filter( lo_filter ).
        lo_request->set_top( 5 ).

        DATA(lo_response) = lo_request->execute( ).
        lo_response->get_business_data(
          IMPORTING
            et_business_data = lt_products
        ).

        out->write( |Matching products: { lines( lt_products ) }| ).

        IF lt_products IS INITIAL.
          out->write( 'No product matched this filter.' ).
        ELSE.
          LOOP AT lt_products INTO DATA(ls_product).
            out->write(
              |{ ls_product-product } - { ls_product-product_type }|
            ).
          ENDLOOP.
        ENDIF.

      CATCH cx_root INTO DATA(lx_error).
        out->write( 'API or connection error:' ).
        out->write( lx_error->get_text( ) ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
