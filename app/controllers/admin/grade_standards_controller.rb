class Admin::GradeStandardsController < Admin::HomeController

  def index
    @grade_standards = GradeStandard.order(grade_order: :asc)
    @grade_standard_will_be_modifieds = GradeStandardWillBeModified.all
    @top_10_users = UserActivityScore.page(params[:page]).per(10).order(total_score: :desc)
  end

  def new
    @grade_standard = GradeStandardWillBeModified.new
  end

  def create
    @grade_standard = GradeStandardWillBeModified.new(grade_standard_params)
    if @grade_standard.save
      flash['success'] = "<#{@grade_standard.name}> 등급을 성공적으로 생성하였습니다"
      redirect_to admin_grade_standards_path
    else
      flash['error'] = '필수 입력값을 모두 입력해주세요'
      render :new
    end
  end

  def edit
    @grade_standard = GradeStandardWillBeModified.find_by(grade_standard_id: params[:id])
    return unless @grade_standard.nil?
    original_grade_standard = GradeStandard.find_by_id(params[:id])
    @grade_standard = GradeStandardWillBeModified.create(grade_standard_id: params[:id], image: original_grade_standard.image, name: original_grade_standard.name, percent_standard: original_grade_standard.percent_standard)
  end

  def update
    @grade_standard = GradeStandardWillBeModified.find_by_id(params[:id])
    if @grade_standard.update(grade_standard_params)
      flash['success'] = "<#{@grade_standard.name}> 등급을 성공적으로 수정하였습니다"
      redirect_to admin_grade_standards_path
    else
      flash['error'] = '필수 입력값을 모두 입력해주세요'
      render :edit
    end
  end

  def destroy
    @grade_standard = GradeStandardWillBeModified.find_by(grade_standard_id: params[:id])
    if @grade_standard
      @grade_standard.update(name: nil, percent_standard: nil, image: nil)
    else
      GradeStandardWillBeModified.create(grade_standard_id: params[:id])
    end
    flash['warning'] = '등급을 삭제하였습니다'
    redirect_to :back
  end

  def cancel_modifiy
    @grade_standard = GradeStandardWillBeModified.find_by_id(params[:id])
    @grade_standard.destroy
    flash['warning'] = '변경 사항을 취소하였습니다'
    redirect_to :back
  end

  private

  def grade_standard_params
    params.require(:grade_standard_will_be_modified).permit(:name,
                                                            :percent_standard,
                                                            :image)
  end
end
