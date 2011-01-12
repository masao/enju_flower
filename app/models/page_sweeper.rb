class PageSweeper < ActionController::Caching::Sweeper
  include ExpireEditableFragment
  observe Patron, Language,
    SeriesStatement, Shelf, Tag, Answer,
    Subject, Classification, Library

  def after_save(record)
    case
    when record.is_a?(Library)
      #expire_fragment(:controller => :libraries, :action => :index, :page => 'menu')
      expire_menu
    when record.is_a?(Shelf)
      # TODO: 書架情報が更新されたときのキャッシュはバッチで削除する
      #record.items.each do |item|
      #  expire_editable_fragment(item, ['holding'])
      #end
    when record.is_a?(Tag)
      record.taggings.collect(&:taggable).each do |taggable|
        expire_editable_fragment(taggable)
      end
    when record.is_a?(Subject)
      expire_editable_fragment(record)
      record.works.each do |work|
        expire_editable_fragment(work)
      end
      record.classifications.each do |classification|
        expire_editable_fragment(classification)
      end
    when record.is_a?(Classification)
      expire_editable_fragment(record)
      record.subjects.each do |subject|
        expire_editable_fragment(subject)
      end
    when record.is_a?(Language)
      Rails.cache.fetch('language_all'){Language.all}.each do |language|
        expire_fragment(:controller => 'page', :locale => language.iso_639_1).to_sym
      end
    when record.is_a?(SeriesStatement)
      record.manifestations.each do |manifestation|
        expire_editable_fragment(manifestation, ['detail'])
      end
    when record.is_a?(SubjectHeadingTypeHasSubject)
      expire_editable_fragment(record.subject)
    when record.is_a?(PictureFile)
      case
      when record.picture_attachable.is_a?(Manifestation)
        expire_editable_fragment(record.picture_attachable, ['picture_file', 'book_jacket'])
      when record.picture_attachable.is_a?(Patron)
        expire_editable_fragment(record.picture_attachable, ['picture_file'])
      end
    when record.is_a?(Answer)
      record.items.each do |item|
        expire_editable_fragment(item.manifestation, ['detail'])
      end
    end
  end

  def after_destroy(record)
    after_save(record)
  end

  def expire_menu
    I18n.available_locales.each do |locale|
      Rails.cache.fetch('role_all'){Role.all}.each do |role|
        expire_fragment(:controller => :page, :page => 'menu', :role => role.name, :locale => locale)
      end
    end
  end
end
