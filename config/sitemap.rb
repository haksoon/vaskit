# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://vaskit.kr"

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end

  add landing_path

  add collections_path
  Collection.find_each do |collection|
    add collection_path(collection.id), :lastmod => collection.updated_at
  end

  add asks_path
  Ask.find_each do |ask|
    add ask_path(ask.id), :lastmod => ask.updated_at
  end
  add new_ask_path

  add videos_path

  add users_path
  add users_history_path
  add users_settings_path
  add users_settings_edit_profile_path
  add users_settings_edit_password_path
  add users_settings_edit_push_alarm_path
  add users_settings_edit_email_alarm_path

  add new_user_session_path
  add new_user_registration_path

  add users_forgot_password_path
  add users_reset_password_path

  add contact_us_etc_index_path
  add faq_help_etc_index_path
  add access_term_etc_index_path
  add privacy_policy_etc_index_path
end
