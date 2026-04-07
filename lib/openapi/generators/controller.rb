require_relative "base"

module Openapi
  module Generators
    class Controller < Base
      GENERATED_DIR   = Rails.root.join("app/controllers/generated")
      CONTROLLERS_DIR = Rails.root.join("app/controllers")

      def run
        if @resources.empty?
          puts "[WARN] 対象リソースが見つかりませんでした"
          return
        end

        @resources.each do |resource|
          write_base_controller(resource)
          write_impl_controller(resource)
        end
      end

      private

      # Baseコントローラーを生成する（毎回フル上書き）
      #
      # @param resource [Openapi::Parser::ResourceInfo]
      def write_base_controller(resource)
        model_name      = resource.resource_name.singularize
        base_class_name = class_name(resource, suffix: "BaseController")

        dir       = GENERATED_DIR.join(*resource.namespace)
        FileUtils.mkdir_p(dir)
        file_path = dir.join("#{resource.resource_name}_base_controller.rb")

        content = render_template(
          "base_controller.erb",
          base_class_name:    base_class_name,
          namespace:          resource.namespace,
          model_name:         model_name,
          actions:            resource.actions,
          permit_params:      resource.permit_params,
          strong_params_code: build_strong_params_code(model_name, resource.permit_params, resource.params_wrapper_key)
        )

        File.write(file_path, content)
        puts "[上書き]  #{pretty_path(file_path)}"
      end

      # 実装コントローラーを生成する（存在しない場合のみ）
      #
      # @param resource [Openapi::Parser::ResourceInfo]
      def write_impl_controller(resource)
        model_name      = resource.resource_name.singularize
        base_class_name = class_name(resource, suffix: "BaseController")
        impl_class_name = class_name(resource, suffix: "Controller")

        dir       = CONTROLLERS_DIR.join(*resource.namespace)
        FileUtils.mkdir_p(dir)
        file_path = dir.join("#{resource.resource_name}_controller.rb")

        if file_path.exist?
          puts "[スキップ] #{pretty_path(file_path)} (既存ファイルを保護)"
          return
        end

        content = render_template(
          "impl_controller.erb",
          base_class_name: base_class_name,
          impl_class_name: impl_class_name,
          namespace:       resource.namespace,
          model_name:      model_name
        )

        File.write(file_path, content)
        puts "[新規作成] #{pretty_path(file_path)}"
      end

      # permit_params の配列から strong parameters のコード文字列を生成する
      #
      # wrapper_key が指定されている場合:
      #   params.require(:wrapper_key).permit(...)
      # wrapper_key が nil の場合（フラット構造）:
      #   params.permit(...)
      #
      # 例（フラット）:
      #   build_strong_params_code("signup", ["email", "password"], nil)
      #   # => 'params.permit(:email, :password)'
      #
      # 例（ラッパーあり）:
      #   build_strong_params_code("user", ["name", "email"], "user")
      #   # => 'params.require(:user).permit(:name, :email)'
      #
      # @param model_name [String]
      # @param permit_params [Array<String, Hash>]
      # @param wrapper_key [String, nil]
      # @return [String]
      def build_strong_params_code(model_name, permit_params, wrapper_key = nil)
        if permit_params.empty?
          wrapper_key ? "params.require(:#{wrapper_key})" : "params"
        elsif wrapper_key
          "params.require(:#{wrapper_key}).permit(#{build_permit_list(permit_params)})"
        else
          "params.permit(#{build_permit_list(permit_params)})"
        end
      end

      # permit リストをコード文字列に変換する（再帰）
      #
      # @param params [Array<String, Hash>]
      # @return [String]
      def build_permit_list(params)
        params.map do |item|
          case item
          when String
            ":#{item}"
          when Hash
            item.map do |key, value|
              case value
              when Array
                if value.empty?
                  "#{key}: []"
                else
                  "#{key}: [#{build_permit_list(value)}]"
                end
              end
            end.join(", ")
          end
        end.join(", ")
      end
    end
  end
end
