RSpec::Matchers.define :have_ckeditor do |label, with:|
  define_method :textarea do
    page.within(".translatable-fields") do
      has_field?(label, visible: false) && find_field(label, visible: false)
    end
  end

  match do
    textarea && has_css?("[aria-label~='#{textarea[:id]}']", exact_text: with)
  end

  failure_message do
    if textarea
      text = page.find("[aria-label~='#{textarea[:id]}']").text

      "expected to find visible CKEditor '#{label}' with '#{with}', but had '#{text}'"
    else
      "expected to find visible CKEditor '#{label}' but there were no matches."
    end
  end
end
