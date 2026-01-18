@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View For Vendor Approval & Workflow'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity zvendor_basicview as select from zvendor02
{
    key vid as Vid,
    vendor_name as VendorName,
    pan_number as PanNumber,
    gstin_number as GstinNumber,
    contact_name as ContactName,
    contact_email as ContactEmail,
    contact_phone as ContactPhone,
    bank_account as BankAccount,
    ifsc_code as IfscCode,
    category as Category,
    country as Country,
    status as Status,
    created_at as CreatedAt,
    created_by as CreatedBy,
    modified_at as ModifiedAt,
    modified_by as ModifiedBy,
    last_actionat as LastActionat,
    last_actionby as LastActionby,
    version as Version
}
