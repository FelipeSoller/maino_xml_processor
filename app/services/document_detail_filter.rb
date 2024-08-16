class DocumentDetailFilter
  def initialize(scope, params)
    @scope = scope
    @params = params
  end

  def apply
    filter_by_date
    filter_by_emit_name
    filter_by_dest_name
    filter_by_vprod
    filter_by_xprod
    filter_by_ncm
    filter_by_cfop
    @scope
  end

  private

  def filter_by_date
    if @params[:start_date].present?
      @scope = @scope.where('dhemi >= ?', @params[:start_date])
    end

    if @params[:end_date].present?
      @scope = @scope.where('dhemi <= ?', @params[:end_date])
    end
  end

  def filter_by_emit_name
    if @params[:emit_name].present?
      @scope = @scope.joins(:emit).where('emits.xnome ILIKE ?', "%#{@params[:emit_name]}%")
    end
  end

  def filter_by_dest_name
    if @params[:dest_name].present?
      @scope = @scope.joins(:dest).where('dests.xnome ILIKE ?', "%#{@params[:dest_name]}%")
    end
  end

  def filter_by_vprod
    if @params[:min_vprod].present?
      @scope = @scope.where('vprod >= ?', @params[:min_vprod])
    end

    if @params[:max_vprod].present?
      @scope = @scope.where('vprod <= ?', @params[:max_vprod])
    end
  end

  def filter_by_xprod
    if @params[:xprod].present?
      @scope = @scope.joins(:dets).where('dets.xprod ILIKE ?', "%#{@params[:xprod]}%")
    end
  end

  def filter_by_ncm
    if @params[:ncm].present?
      @scope = @scope.joins(:dets).where('dets.ncm ILIKE ?', "%#{@params[:ncm]}%")
    end
  end

  def filter_by_cfop
    if @params[:cfop].present?
      @scope = @scope.joins(:dets).where('dets.cfop ILIKE ?', "%#{@params[:cfop]}%")
    end
  end
end
