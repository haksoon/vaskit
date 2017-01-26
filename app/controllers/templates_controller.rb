class TemplatesController < ApplicationController

  # GET templates/faq_help.html
  def faq_help
    render layout: "layout_template"
  end

  # GET templates/access_term.html
  def access_term
    render layout: "layout_template"
  end

  # GET templates/privacy_policy.html
  def privacy_policy
    render layout: "layout_template"
  end

end
