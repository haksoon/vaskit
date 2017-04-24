class Admin::GradeStandardsController < Admin::HomeController

  # GET /admin/grade_standards
  def index
    @grade_standards = GradeStandard.all.includes(:grade_standard_will_be_modified)
    @new_grade_standards = GradeStandardWillBeModified.where(grade_standard_id: nil)
    @user_scores = UserActivityScore.includes(:user)
                                    .order(total_score: :desc)
                                    .select(:user_id, :total_score)
                                    .as_json(include: [user: { only: [:string_id] }])
    @top_10_users = UserActivityScore.includes(:user).order(total_score: :desc).limit(10)
  end

  # GET /admin/grade_standards/:id
  def show
    @grade_standard = GradeStandard.find(params[:id])
    @grade_users = UserActivityScore.where(grade_standard_id: params[:id])
                                    .order(total_score: :desc).page(params[:page]).per(10)
  end

  # GET /admin/grade_standards/new
  def new
    @grade_standard = GradeStandardWillBeModified.new
  end

  # POST /admin/grade_standards
  def create
    @grade_standard = GradeStandardWillBeModified.new(grade_standard_params)
    if @grade_standard.save
      flash['success'] = '등급 생성이 예약되었습니다'
      redirect_to admin_grade_standards_path
    else
      flash['error'] = '필수 입력값을 모두 입력해주세요'
      render :new
    end
  end

  # GET /admin/grade_standards/:id/edit
  def edit
    @grade_standard = GradeStandardWillBeModified.find_by(grade_standard_id: params[:id])
    return unless @grade_standard.nil?
    original_grade_standard = GradeStandard.find(params[:id])
    @grade_standard = GradeStandardWillBeModified.create(grade_standard_id: params[:id],
                                                         name: original_grade_standard.name,
                                                         percent_standard: original_grade_standard.percent_standard,
                                                         image: original_grade_standard.image)
  end

  # PATCH /admin/grade_standards/:id
  def update
    @grade_standard = GradeStandardWillBeModified.find(params[:id])
    if @grade_standard.update(grade_standard_params)
      flash['success'] = '등급 수정이 예약되었습니다'
      redirect_to admin_grade_standards_path
    else
      flash['error'] = '필수 입력값을 모두 입력해주세요'
      render :edit
    end
  end

  # DELETE /admin/grade_standards/:id
  def destroy
    @grade_standard = GradeStandardWillBeModified.find_by(grade_standard_id: params[:id])
    if @grade_standard
      @grade_standard.update(name: nil, percent_standard: nil, image: nil)
    else
      GradeStandardWillBeModified.create(grade_standard_id: params[:id])
    end
    flash['warning'] = '등급 삭제가 예약되었습니다'
    redirect_to :back
  end

  # PATCH /admin/grade_standards/:id/cancel_modify
  def cancel_modify
    GradeStandardWillBeModified.find(params[:id]).destroy
    flash['warning'] = '예약된 변경 사항을 취소하였습니다'
    redirect_to :back
  end

  # PUT /admin/grade_standards/:id/cancel_modify
  def force_update
    GradeStandardWillBeModified.update_by_daily
    GradeStandard.update_by_daily
    UserActivityScore.update_by_daily
    flash['success'] = '강제 업데이트를 완료하였습니다'
    redirect_to admin_grade_standards_path
  end

  private

  def grade_standard_params
    params.require(:grade_standard_will_be_modified).permit(:name,
                                                            :percent_standard,
                                                            :image)
  end
end
