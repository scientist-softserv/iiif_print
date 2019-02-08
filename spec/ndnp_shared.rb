require 'newspaper_works_fixtures'

RSpec.shared_context "ndnp fixture setup", shared_context: :metadata do
  let(:ndnp_fixture_path) do
    File.join(NewspaperWorksFixtures.file_fixtures, 'ndnp')
  end

  # `batch_local` example issue:
  let(:issue1) do
    File.join(
      ndnp_fixture_path,
      'batch_local/sn85058233/17082901001/1935080201/1935080201.xml'
    )
  end

  # `batch_test_ver01` example issue:
  let(:issue2) do
    File.join(
      ndnp_fixture_path,
      'batch_test_ver01/data/sn85025202/00279557281/1857021401/1857021401.xml'
    )
  end
end
