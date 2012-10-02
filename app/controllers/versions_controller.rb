# Old versions of Person. Only goes back since we started using Vestal Versions.
class VersionsController < ApplicationController
  force_https

  before_filter :require_current_person
  before_filter :assign_person
  before_filter :require_same_person_or_administrator_or_editor

  def assign_person
    @person = Person.find(params[:person_id])
  end
end
