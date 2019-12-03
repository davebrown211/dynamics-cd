function onSave() {
  const jobTitleValue = Xrm.Page.getAttribute("jobtitle").getValue()
  const firstNameAttribute = Xrm.Page.getAttribute("firstname")
  const firstNameValue = firstNameAttribute.getValue()
  firstNameAttribute.setValue(`${jobTitleValue} ${firstNameValue} test`)
}