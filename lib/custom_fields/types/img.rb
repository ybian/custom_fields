module CustomFields

  module Types

    module Img

      module Field; end

      module Target

        extend ActiveSupport::Concern

        module ClassMethods

          # Adds a file field (using carrierwave)
          #
          # @param [ Class ] klass The class to modify
          # @param [ Hash ] rule It contains the name of the field and if it is required or not
          #
          def apply_img_custom_field(klass, rule)
            name = rule['name']

            klass.mount_uploader name, ImgUploader

            if rule['localized'] == true
              klass.replace_field name, ::String, true
            end
          end

          # Build a hash storing the url for a file custom field of an instance.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the file custom field
          #
          # @return [ Hash ] field name => url or empty hash if no file
          #
          def img_attribute_get(instance, name)
            if instance.send(:"#{name}?") #"
              value = instance.send(name.to_sym).url
              { name => value, "#{name}_url" => value }
            else
              {}
            end
          end

          # Set the value for the instance and the file field specified by
          # the 2 params.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the file custom field
          # @param [ Hash ] attributes The attributes used to fetch the values
          #
          def file_attribute_set(instance, name, attributes)
            [name, "remote_#{name}_url", "remove_#{name}"].each do |_name|
              self.default_attribute_set(instance, _name, attributes)
            end.compact
          end

        end

      end

      class ImgUploader < ::CarrierWave::Uploader::Base
        # Include RMagick or MiniMagick support:
        # include CarrierWave::RMagick
        include CarrierWave::MiniMagick

        # Choose what kind of storage to use for this uploader:
        storage :grid_fs
        # storage :fog

        # Override the directory where uploaded files will be stored.
        # This is a sensible default for uploaders that are meant to be mounted:
        def store_dir
          "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
        end

        # Provide a default URL as a default if there hasn't been a file uploaded:
        # def default_url
        #   # For Rails 3.1+ asset pipeline compatibility:
        #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
        #
        #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
        # end

        # Process files as they are uploaded:
        # process :scale => [200, 300]
        #
        # def scale(width, height)
        #   # do something
        # end

        # Create different versions of your uploaded files:
        # version :thumb do
        #   process :resize_to_fit => [50, 50]
        # end
        # Process files as they are uploaded:
        process resize_to_limit: [1000, 1000]

        # Create different versions of your uploaded files:
        version :medium do
          process resize_to_limit: [400, 400]
        end

        version :small do
          process resize_to_limit: [200, 200]
        end

        # Add a white list of extensions which are allowed to be uploaded.
        # For images you might use something like this:
        def extension_white_list
          %w(jpg jpeg gif png)
        end

        def filename
          return nil unless original_filename
          @name ||= Digest::MD5.hexdigest(cache_id)
          extension = nil
          if file.respond_to? :extension
            extension = file.extension
          else
            path_elements = path.split('.')
            extension = path_elements.last if path_elements.size > 1
          end

          if extension
            "#{@name}.#{extension}"
          else
            "#{@name}"
          end
        end
      end

    end

  end

end
