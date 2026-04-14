class CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!
  before_action :set_company, only: [:show, :edit, :update, :destroy]


  def index
    @companies = Company.all
  end

  def show
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    if @company.save
      redirect_to companies_path, notice: '会社を登録しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @company.update(company_params)
      redirect_to company_path(@company.id), notice: '会社情報を更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @company.destroy
      redirect_to companies_path, notice: '会社を削除しました。'
    else
      render :show, status: :unprocessable_entity
    end
  end



  private

  def set_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:company_name, :email, :phone)
  end

end
