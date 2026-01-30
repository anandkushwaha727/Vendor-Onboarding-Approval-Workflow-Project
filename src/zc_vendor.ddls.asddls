@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Project View for Vendor'
@Metadata.ignorePropagatedAnnotations: true


@UI.headerInfo: {
  typeName: 'Vendor',
  typeNamePlural: 'Vendor Onboarding Requests',
  title: { value: 'VendorName' }
}
@UI.presentationVariant: [{ 
requestAtLeast: ['VendorName']
 }]
 
 
define root view entity ZC_VENDOR  provider contract transactional_query as projection on zvendor_root

{



  @UI.identification: [
    {
    
      position: 10,
      type: #FOR_ACTION,
      dataAction: 'Submit',
      label: 'Submit'
    },
    {
      position: 20,
      type: #FOR_ACTION,
      dataAction: 'ApproveByManager',
      label: 'ApproveByManager'
    },
    {
      position: 30,
      type: #FOR_ACTION,
      dataAction: 'ApproveByFinance',
      label: 'ApproveByFinance'
    },
     {
      position: 40,
      type: #FOR_ACTION,
      dataAction: 'reject',
      label: 'Recject'
    }
  ]
  
  

   @UI.facet: [
  {
    id: 'General',
    type: #IDENTIFICATION_REFERENCE,
    label: 'General Information',
    position: 10
  }
]

  key Vid,

  @UI.lineItem: [{ position: 20 }]
  @UI.identification: [{ position: 20 }]
  @UI.selectionField: [{position:20 }]
  VendorName,

  
  @UI.identification: [{ position: 30 }]
  PanNumber,
  @UI.identification: [{ position: 40 }]

  GstinNumber,
@UI.lineItem: [{ position: 50 }]
  @UI.identification: [{ position: 50 }]
  ContactName,

 
  @UI.identification: [{ position: 60 }]
  ContactEmail,

  
  @UI.identification: [{ position: 80 }]
  ContactPhone,

  
  @UI.identification: [{ position: 90 }]
  BankAccount,

  
  @UI.identification: [{ position: 91 }]
  IfscCode,
  @UI.identification: [{ position: 92 }]
  @UI.lineItem: [{ position: 92 }]
 @Consumption.valueHelpDefinition: [{
  entity: {
    name: 'ZVH_VENDOR_CATEGORY',
    element: 'Category'
  }
}]
@UI.selectionField: [{ position: 92 }]
  Category,

 @UI.lineItem: [{ position: 93 }]
  @UI.identification: [{ position: 93 }]
  @UI.selectionField: [{ position: 93 }]
  Country,

 @UI.lineItem: [{ position: 94 }]
 @UI.selectionField: [{ position: 94 }]
  Status,

  CreatedAt,
  CreatedBy,
  ModifiedAt,
  ModifiedBy,
  @UI.lineItem: [{ position: 95}]
  LastActionat,
  @UI.lineItem: [{ position: 96}]
  LastActionby,
  Version
}
