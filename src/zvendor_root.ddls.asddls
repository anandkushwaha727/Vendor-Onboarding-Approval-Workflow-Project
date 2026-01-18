@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendor'
@Metadata.ignorePropagatedAnnotations: true



define root view entity zvendor_root
  as select from zvendor_basicview
{

   key Vid,
    VendorName,
    PanNumber,
    GstinNumber,
    ContactName,
    ContactEmail,
    ContactPhone,
    BankAccount,
    IfscCode,
    Category,
    Country,
    Status,
    @Semantics.systemDateTime.createdAt: true
    CreatedAt,
    @Semantics.user.createdBy: true
    CreatedBy,
    @Semantics.systemDateTime.lastChangedAt: true
    ModifiedAt,
    @Semantics.user.lastChangedBy: true
    ModifiedBy,
    LastActionat,
    LastActionby,
    Version
}
