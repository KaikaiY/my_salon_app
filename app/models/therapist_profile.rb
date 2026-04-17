class TherapistProfile < ApplicationRecord
  belongs_to :user

  scope :published_only, -> { where(published: true) }

  validates :user_id, uniqueness: true
  validates :bio, :specialty, :career, presence: true
  validate :user_must_be_therapist

  private

  def user_must_be_therapist
    return if user&.therapist?

    errors.add(:user, 'は施術者である必要があります')
  end
end
