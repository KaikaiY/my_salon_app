class TherapistProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_therapist_profile, only: %i[show edit update]
  before_action :ensure_admin!, only: :index
  before_action :ensure_therapist!, only: %i[new create edit update]
  before_action :ensure_profile_owner!, only: %i[edit update]
  before_action :ensure_profile_viewable!, only: :show

  def index
    @therapist_profiles = TherapistProfile.includes(:user).order(created_at: :desc)
  end

  def show
  end

  def new
    if current_user.therapist_profile.present?
      redirect_to edit_therapist_profile_path(current_user.therapist_profile), alert: 'プロフィールはすでに作成されています'
      return
    end

    @therapist_profile = current_user.build_therapist_profile
  end

  def create
    if current_user.therapist_profile.present?
      redirect_to edit_therapist_profile_path(current_user.therapist_profile), alert: 'プロフィールはすでに作成されています'
      return
    end

    @therapist_profile = current_user.build_therapist_profile(therapist_profile_params)

    if @therapist_profile.save
      redirect_to therapist_profile_path(@therapist_profile), notice: '施術者プロフィールを登録しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @therapist_profile.update(therapist_profile_params)
      redirect_to therapist_profile_path(@therapist_profile), notice: '施術者プロフィールを更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_therapist_profile
    @therapist_profile = TherapistProfile.find(params[:id])
  end

  def ensure_therapist!
    return if current_user&.therapist?

    redirect_to root_path, alert: '権限がありません'
  end

  def ensure_profile_owner!
    return if @therapist_profile.user == current_user

    redirect_to root_path, alert: '権限がありません'
  end

  def ensure_profile_viewable!
    return if @therapist_profile.published?
    return if current_user.admin? || current_user == @therapist_profile.user

    redirect_to root_path, alert: 'このプロフィールはまだ公開されていません'
  end

  def therapist_profile_params
    params.require(:therapist_profile).permit(:bio, :specialty, :career, :published)
  end
end
