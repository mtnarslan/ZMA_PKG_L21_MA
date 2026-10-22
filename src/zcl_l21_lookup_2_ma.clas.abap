CLASS zcl_l21_lookup_2_ma DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.

ENDCLASS.



CLASS zcl_l21_lookup_2_ma IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    DATA lt_product_descriptions TYPE TABLE OF
    zsc_l21_prod_ma=>tys_a_product_description_type.

    DATA lt_range TYPE if_rap_query_filter=>tt_range_option.
    lt_range = VALUE #(
     ( sign = 'I' option = 'EQ' low = 'TR' )
    ).


    TRY.
        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
            comm_scenario = 'ZBTP_TRIAL_SAP_COM_0309'
            ).

        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination(
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
                'A_PRODUCT_DESCRIPTION'
              )->create_request_for_read( ).

        DATA(lo_lookup) =
              lo_request->create_filter_factory( )->create_by_range(
                iv_property_path = 'LANGUAGE'
                it_range         = lt_range
              ).

            lo_request->set_filter( lo_lookup ).
            lo_request->set_top( 100 ).

            DATA(lo_response) = lo_request->execute( ).
            lo_response->get_business_data(
              IMPORTING
                et_business_data = lt_product_descriptions
            ).

            IF lt_product_descriptions IS NOT INITIAL.
                out->write( 'S/4HANA products via OData proxy' ).
                out->write( |Matching Products : { lines( lt_product_descriptions ) }| ).

                LOOP AT lt_product_descriptions INTO DATA(lt_product_description).
                    out->write(
                       |Etag :{ lt_product_description-etag }  | &&
                       |Product :{ lt_product_description-product }  | &&
                       |Language :{ lt_product_description-language }  | &&
                       |ProductDescription :{ lt_product_description-product_description } |
                    ).
                 ENDLOOP.
                ELSE.
                    out->write( |Matching Products : { lines( lt_product_descriptions ) }| ).
                    out->write( 'No product matched this filter.' ).

            ENDIF.

       CATCH cx_root INTO DATA(lx_error).
        out->write( 'API or connection error:' ).
        out->write( lx_error->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
