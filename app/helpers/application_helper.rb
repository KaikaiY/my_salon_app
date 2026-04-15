module ApplicationHelper
  def status_label_classes(status, base: 'status-chip')
    [base, status_variant_class(status)].join(' ')
  end

  private

  def status_variant_class(status)
    case status.to_s
    when 'pending'
      'status-pending'
    when 'accepted'
      'status-accepted'
    when 'approved', 'confirmed', 'completed'
      'status-positive'
    when 'reserved'
      'status-active'
    when 'cancelled', 'expired'
      'status-negative'
    else
      'status-neutral'
    end
  end
end
