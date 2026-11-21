# "Names & sections" page: manage sections and the members in them.
class MembersController < ApplicationController
  def index
    @sections = Section.includes(:members).to_a
  end

  # Adds several names at once (one per line) to a section.
  def bulk_create
    section = Section.find(params[:section_id])
    names = params[:names].to_s.lines.map { |l| l.sub(/\A\s*\d+[.)]\s*/, "").strip }.reject(&:empty?)
    names.each { |n| section.members.create!(name: n) }
    redirect_to members_path(anchor: "section-#{section.id}"), notice: "Added #{names.size} name(s) to #{section.name}."
  end

  def update
    member = Member.find(params[:id])
    if member.update(params.require(:member).permit(:name, :section_id, :active))
      redirect_to members_path(anchor: "section-#{member.section_id}"), notice: "Saved #{member.name}."
    else
      redirect_to members_path, alert: member.errors.full_messages.to_sentence
    end
  end

  def move
    member = Member.find(params[:id])
    siblings = member.section.members.to_a
    i = siblings.index(member)
    j = params[:direction] == "up" ? i - 1 : i + 1
    if j.between?(0, siblings.size - 1)
      siblings[i], siblings[j] = siblings[j], siblings[i]
      Member.transaction { siblings.each_with_index { |m, pos| m.update_column(:position, pos) } }
    end
    redirect_to members_path(anchor: "section-#{member.section_id}")
  end

  def destroy
    member = Member.find(params[:id])
    if member.contributions.exists?
      member.update!(active: false)
      redirect_to members_path, notice: "#{member.name} has recorded amounts, so they were marked inactive instead of deleted. Their history stays in old months."
    else
      member.destroy!
      redirect_to members_path, notice: "Removed #{member.name}."
    end
  end

  # --- sections ---

  def create_section
    section = Section.new(name: params[:name])
    if section.save
      redirect_to members_path(anchor: "section-#{section.id}"), notice: "Section added."
    else
      redirect_to members_path, alert: section.errors.full_messages.to_sentence
    end
  end

  def update_section
    section = Section.find(params[:id])
    section.update(name: params[:name]) if params[:name].present?
    if params[:direction].present?
      list = Section.all.to_a
      i = list.index(section)
      j = params[:direction] == "up" ? i - 1 : i + 1
      if j.between?(0, list.size - 1)
        list[i], list[j] = list[j], list[i]
        Section.transaction { list.each_with_index { |s, pos| s.update_column(:position, pos) } }
      end
    end
    redirect_to members_path(anchor: "section-#{section.id}")
  end

  def destroy_section
    section = Section.find(params[:id])
    if section.members.exists?
      redirect_to members_path, alert: "Move or remove the names in “#{section.name}” first."
    else
      section.destroy!
      redirect_to members_path, notice: "Section deleted."
    end
  end
end
