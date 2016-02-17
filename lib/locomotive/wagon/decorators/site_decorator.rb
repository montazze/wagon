module Locomotive
  module Wagon

    class SiteDecorator < SimpleDelegator

      include ToHashConcern
      include PersistAssetsConcern

      attr_accessor :__content_assets_pusher__

      def domains
        (__getobj__.domains || []) - ['localhost']
      end

      def metafields_schema
        self[:metafields_schema].try(:to_json)
      end

      def metafields
        replace_with_content_assets_in_hash!(self[:metafields])
        self[:metafields].try(:to_json)
      end

      def picture
        picture_path = __getobj__.picture
        if picture_path && File.exists?(picture_path)
          Locomotive::Coal::UploadIO.new(picture_path, nil, 'icon.png')
        else
          nil
        end
      end

      %i(robots_txt timezone seo_title meta_keywords meta_description).each do |name|
        define_method(name) do
          self[name]
        end
      end

      def __attributes__
        %i(name handle robots_txt locales timezone seo_title meta_keywords meta_description picture metafields_schema metafields)
      end

      def edited?
        (self[:content_version].try(:to_i) || 0) > 0
      end

    end

    class UpdateSiteDecorator < SiteDecorator

      def __attributes__
        %i(picture locales metafields_schema metafields)
      end

    end

  end
end
