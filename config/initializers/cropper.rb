module Paperclip
  class Cropper < Thumbnail
    def transformation_command
      if crop_command
        scale, crop = @current_geometry.transformation_to(@target_geometry, crop?)
        trans = []
        trans << "-coalesce" if animated?
        trans << "-auto-orient" if auto_orient
        trans << "-resize" << %["1024x1024>"]  # 크롭하기 전에 프리뷰 이미지 사이즈로 재조정함
        trans << crop_command
        trans << "+repage -resize" << %["#{scale}"] unless scale.nil? || scale.empty?
        trans << '-layers "optimize"' if animated?
        trans
      else
        super
      end
    end

    def crop_command
      target = @attachment.instance
        if target.cropping?
          ["-crop", "#{target.crop_w}x#{target.crop_h}+#{target.crop_x}+#{target.crop_y}"]
        end
    end
  end
end
