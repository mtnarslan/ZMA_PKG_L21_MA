CLASS zcl_l21_product_proxy_ma DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_l21_product_proxy_ma IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    "The generated SCM row type represents one remote product.
    DATA lt_products TYPE TABLE OF
      zsc_l21_prod_ma=>tys_a_clfn_product_type.

    TRY.
        "1. Resolve the existing S/4HANA connection.
        DATA(lo_destination) =
          cl_http_destination_provider=>create_by_comm_arrangement(
            comm_scenario = 'ZBTP_TRIAL_SAP_COM_0309'
          ).

        "2. Construct the underlying HTTP client.
        DATA(lo_http_client) =
          cl_web_http_client_manager=>create_by_http_destination(
            i_destination = lo_destination
          ).

        "3. Use your generated model for an OData V2 proxy.
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

        "The destination already points to the service root.
        "Do not add that service path a second time.

        "4. Request a list from the Product entity set.
        DATA(lo_request) =
          lo_proxy->create_resource_for_entity_set(
            'A_CLFN_PRODUCT'
          )->create_request_for_read( ).

        "5. Retrieve at most five products.
        lo_request->set_top( 5 ).

        "6. Execute the remote API call.
        DATA(lo_response) = lo_request->execute( ).

        "7. Convert the response into typed ABAP rows.
        lo_response->get_business_data(
          IMPORTING
            et_business_data = lt_products
        ).

        "8. Display a short, readable result.
        out->write( 'S/4HANA products via OData proxy' ).
        out->write( |Products returned: { lines( lt_products ) }| ).

        IF lt_products IS INITIAL.
          out->write( 'The API returned no matching products.' ).
        ELSE.
          LOOP AT lt_products INTO DATA(ls_product).
            out->write(
              |Product: { ls_product-product } | &&
              |Type: { ls_product-product_type } | &&
              |Group: { ls_product-product_group } | &&
              |Unit: { ls_product-base_unit }|
            ).
          ENDLOOP.
        ENDIF.

      CATCH cx_root INTO DATA(lx_error).
        out->write( 'ERROR calling the OData Product API:' ).
        out->write( lx_error->get_text( ) ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
