RSpec.shared_examples 'a persistent work type' do
  before(:all) do
    @work = described_class.new
    @cls = described_class
  end

  it 'is correct instance type' do
    expect(@work).to be_an_instance_of(@cls)
  end
  it 'sets title' do
    @work.title = ['San Diego Evening Tribune']
  end
  it 'initially has nil id' do
    expect(@work.id).to be_nil
  end
  it 'saves' do
    @work.save
  end
  it 'has non-nil id after save' do
    expect(@work.id).to_not be_nil
  end
  it 'appears to be persisted in fcrepo' do
    expect(@cls.all.map { |w| w.id }).to include(@work.id)
  end
  it 'deletes via delete' do
    @work.delete
    expect(@cls.all.map { |w| w.id }).to_not include(@work.id)
  end

end

RSpec.shared_examples 'a PCDM file set' do

  before(:all) do
    @work = described_class.new
    @cls = described_class
  end 

  it 'looks like a fileset by method introspection' do
    expect(@work.file_set?).to be true
  end

  it 'does not look like a work' do
    expect(@work.work?).to be false
  end

  it 'still looks like a PCDM object, though' do
    expect(@work.pcdm_object?).to be true
  end

end

RSpec.shared_examples 'a work and PCDM object' do

  before(:all) do
    @work = described_class.new
    @cls = described_class
  end 
  
  it 'looks like a work' do
    expect(@work.work?).to be true
  end

  it 'also looks like a PCDM object' do
    expect(@work.pcdm_object?).to be true
  end

  it 'does not look like a fileset' do
    expect(@work.file_set?).to be false
  end

end


def model_fixtures(target_type)

  # set up graph of related objects, setting membership on aggregating
  # parents via members setter method, per PCDM Profile for Newspapers.
  publication = NewspaperTitle.new
  publication.title = ["Yesterday's News"]
  #publication.save
  issue1 = NewspaperIssue.new
  issue1.title = ['December 7, 1941']
  #issue1.save
  publication.members.push issue1
  page1 = NewspaperPage.new
  page1.title = ['Page 1']
  page1.pagination = '1'
  page2 = NewspaperPage.new
  page2.title = ['Page 2']
  page2.pagination = '2'
  issue1.members.push(page1, page2)
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
  issue1.save
  publication.save
  page1.save
  page2.save
  article1.save
  article2.save
  container.save

  # return types appropriate to target class: return correct starting point
  # for the object graph of these fixtures, in the context of their use.
  if target_type == NewspaperTitle
    return publication
  end
  if target_type == NewspaperIssue
    return issue1
  end
  if target_type == NewspaperPage
    return page1
  end
  if target_type == NewspaperArticle
    return article2
  end
  if target_type == NewspaperContainer
    return container
  end

end
