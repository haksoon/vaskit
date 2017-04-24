Premailer::Rails.config.merge!(base_url: CONFIG['host'],
                               remove_ids: true,
                               remove_classes: true,
                               adapter: :nokogiri)
