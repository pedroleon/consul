class Legislation::ProcessesController < Legislation::BaseController
  has_filters %w{open next past}, only: :index
  load_and_authorize_resource

  def index
    @current_filter ||= 'open'
    @processes = ::Legislation::Process.send(@current_filter).page(params[:page])
  end

  def show
    if process.active_phase?(:allegations) && process.allegations_phase.started? && draft_version = process.draft_versions.published.last
      redirect_to legislation_process_draft_version_path(process, draft_version)
    elsif process.active_phase?(:debate)
      redirect_to legislation_process_debate_path(process)
    else
      redirect_to legislation_process_allegations_path(process)
    end
  end

  def debate
    if process.debate_phase.started?
      render :debate
    else
      render :phase_not_open
    end
  end

  def draft_publication
    if process.draft_publication.started?
      if draft_version = process.draft_versions.published.last
        redirect_to legislation_process_draft_version_path(process, draft_version)
      else
        render :phase_empty
      end
    else
      render :phase_not_open
    end
  end

  def allegations
    if process.allegations_phase.started?
      if draft_version = process.draft_versions.published.last
        redirect_to legislation_process_draft_version_path(process, draft_version)
      else
        render :phase_empty
      end
    else
      render :phase_not_open
    end
  end

  def result_publication
    if process.result_publication.started?
      if final_version = process.final_draft_version
        redirect_to legislation_process_draft_version_path(process, final_version)
      else
        render :phase_empty
      end
    else
      render :phase_not_open
    end
  end

  private

    def process
      @process ||= ::Legislation::Process.find(params[:process_id])
    end
end
