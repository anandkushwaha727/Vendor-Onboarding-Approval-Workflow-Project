@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View For Category Fixed value'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZVH_VENDOR_CATEGORY as select from zvendor_cat_t
{
@ObjectModel.text.element: ['CategoryText']

    key category as Category,
    text as CategoryText
}
