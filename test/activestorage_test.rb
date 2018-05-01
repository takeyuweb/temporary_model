require 'test_helper'

class TemporaryModel::ActiveStorageTest < ActiveSupport::TestCase

  temporary_model 'Entry' do
    define_table do
      # (no op)
    end
    has_one_attached :attachment
    has_many_attached :attachments
  end

  setup do
    @entry = Entry.new
    @entry.attachment.attach(create_blob)
    @entry.attachments.attach([create_blob, create_blob])
    @entry.save!
  end

  test 'has_one_attached' do
    assert @entry.attachment.attached?
  end

  test 'has_many_attached' do
    assert_equal 2, @entry.attachments.size
  end

  private

    def create_blob
      ActiveStorage::Blob.create_after_upload!(io: StringIO.new('Hello world!'),
                                               filename: 'hello.txt',
                                               content_type: 'text/plain')
    end

end
