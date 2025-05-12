module FormHelpers
  def create_test_form(attributes = {})
    default_attributes = {
      name: "Test Form",
      background_color: "#ffffff",
      text_color: "#000000",
      button_color: "#0000ff",
      button_text_color: "#ffffff",
      button_text: "Submit",
      header_text: "Test form",
      target_email_address: "test@example.com"
    }
    
    Form.create!(default_attributes.merge(attributes))
  end

  def valid_form_attributes(attributes = {})
    default_attributes = {
      name: "New Form", 
      button_text: "New Form",
      header_text: "New Header",
      target_email_address: "new@example.com"
    }
    
    default_attributes.merge(attributes)
  end
end