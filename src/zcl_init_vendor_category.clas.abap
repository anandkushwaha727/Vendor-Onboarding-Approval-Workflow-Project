CLASS zcl_init_vendor_category DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.



CLASS zcl_init_vendor_category IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA lt_category TYPE STANDARD TABLE OF zvendor_cat_t.
    DATA ls_category TYPE zvendor_cat_t.

    " Step 1: Clear existing data (DEV setup only)
    DELETE FROM zvendor_cat_t.

    " Step 2: Prepare Goods
    ls_category-category = 'G'.
    ls_category-text     = 'Goods'.
    APPEND ls_category TO lt_category.

    " Step 3: Prepare Services
    CLEAR ls_category.
    ls_category-category = 'S'.
    ls_category-text     = 'Services'.
    APPEND ls_category TO lt_category.

    " Step 4: Insert
    INSERT zvendor_cat_t FROM TABLE @lt_category.

    " Step 5: Commit (MANDATORY in ABAP Cloud)
    COMMIT WORK.

    out->write( 'Vendor category master data inserted successfully.' ).

  ENDMETHOD.

ENDCLASS.


