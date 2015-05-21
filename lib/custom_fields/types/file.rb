module CustomFields

  module Types

    module File

      module Field; end

      module Target

        extend ActiveSupport::Concern

        module ClassMethods

          # Adds a file field (using carrierwave)
          #
          # @param [ Class ] klass The class to modify
          # @param [ Hash ] rule It contains the name of the field and if it is required or not
          #
          def apply_file_custom_field(klass, rule)
            name = rule['name']

            klass.mount_uploader name, FileUploader

            if rule['localized'] == true
              klass.replace_field name, ::String, true
            end

            if rule['required']
              klass.validates_presence_of name
            end
          end

          # Build a hash storing the url for a file custom field of an instance.
          #
          # @param [ Object ] instance An instance of the class enhanced by the custom_fields
          # @param [ String ] name The name of the file custom field
          #
          # @return [ Hash ] field name => url or empty hash if no file
          #
          def file_attribute_get(instance, name)
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

      class FileUploader < ::CarrierWave::Uploader::Base
        storage :grid_fs

        def store_dir
          "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
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
