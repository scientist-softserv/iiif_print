# Shared Model
RSpec.shared_examples 'a persistent work type' do
  let(:work) { described_class.new }
  let(:cls) { described_class }

  describe 'class membership' do
    it 'has correct instance type' do
      expect(work).to be_an_instance_of(cls)
    end

    it 'initially has nil id' do
      expect(work.id).to be_nil
    end
  end

  describe 'object persistence' do
    before do
      work.title = ['San Diego Evening Tribune']
      work.save!
    end

    it 'has non-nil id after save' do
      expect(work.id).not_to be_nil
    end

    it 'appears to be persisted in fcrepo' do
      expect(cls.all.map(&:id)).to include(work.id)
    end

    describe 'deletion' do
      it 'deletes via delete' do
        work.delete
        expect(cls.all.map(&:id)).not_to include(work.id)
      end
    end
  end
end

RSpec.shared_examples 'a PCDM file set' do
  let(:work) { described_class.new }
  let(:cls) { described_class }

  it 'looks like a fileset by method introspection' do
    expect(work.file_set?).to be true
  end

  it 'does not look like a work' do
    expect(work.work?).to be false
  end

  it 'still looks like a PCDM object, though' do
    expect(work.pcdm_object?).to be true
  end
end

RSpec.shared_examples 'a work and PCDM object' do
  let(:work) { described_class.new }
  let(:cls) { described_class }

  it 'looks like a work' do
    expect(work.work?).to be true
  end

  it 'also looks like a PCDM object' do
    expect(work.pcdm_object?).to be true
  end

  it 'does not look like a fileset' do
    expect(work.file_set?).to be false
  end
end

# rubocop:disable Metrics/MethodLength
def model_fixtures(target_type)
  # set up graph of related objects, setting membership on aggregating
  # parents via members setter method, per PCDM Profile for Newspapers.
  publication = NewspaperTitle.new
  publication.title = ["Yesterday's News"]
  publication.lccn = 'sn1234567'
  issue1 = NewspaperIssue.new
  issue1.title = ['December 7, 1941']
  issue1.publication_date = '1941-12-07'
  issue1.resource_type = ["newspaper"]
  issue1.language = ["eng"]
  issue1.held_by = "Marriott Library"
  # issue1.save
  publication.members.push issue1
  page1 = NewspaperPage.new
  page1.title = ['Page 1']
  page1.page_number = '1'
  page1.height = "200"
  page1.width = "200"
  page2 = NewspaperPage.new
  page2.title = ['Page 2']
  page2.page_number = '2'
  page2.height = "200"
  page2.width = "200"
  issue1.ordered_members << page1
  issue1.ordered_members << page2
  article1 = NewspaperArticle.new
  article1.title = ['Happening now']
  article2 = NewspaperArticle.new
  article2.title = ['Yesterday Summary']
  # issue aggregates articles
  issue1.members.push(article1, article2)
  # article has pages associated, article aggregates pages:
  article1.members.push(page1)
  # presume article 2 has a jump
  article2.members.push(page1, page2)
  # container for title, has a page
  container = NewspaperContainer.new
  container.title = ['Reel123a']
  publication.members.push(container)
  container.members.push(page1, page2)

  # save swarm, persist all the things!
  issue1.save!
  container.save!
  publication.save!
  page1.save!
  page2.save!
  article1.save!
  article2.save!

  # return types appropriate to target class: return correct starting point
  # for the object graph of these fixtures, in the context of their use.
  return publication if target_type == NewspaperTitle
  return issue1 if target_type == NewspaperIssue
  return page1 if target_type == NewspaperPage
  return article2 if target_type == NewspaperArticle
  return container if target_type == NewspaperContainer

  # return multiple objects as needed for testing
  return [page1, page2] if target_type == :newspaper_pages
end
# rubocop:enable Metrics/MethodLength
