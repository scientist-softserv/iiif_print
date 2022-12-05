require 'newspaper_works_fixtures'

RSpec.shared_context "ndnp fixture setup", shared_context: :metadata do
  let(:ndnp_fixture_path) do
    path = File.join(IiifPrintFixtures.file_fixtures, 'ndnp')
    whitelist = Hyrax.config.whitelisted_ingest_dirs
    whitelist.push(path) unless whitelist.include?(path)
    path
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

  let(:reel1) do
    File.join(
      ndnp_fixture_path,
      'batch_test_ver01/data/sn84038814/00279557177/00279557177.xml'
    )
  end

  # reel with no explicit reel number, but containing it in mets/@LABEL
  let(:reel2) do
    File.join(
      ndnp_fixture_path,
      'batch_test_ver01/data/sn85025202/00279557281/00279557281_1.xml'
    )
  end

  let(:batch1) do
    File.join(
      ndnp_fixture_path,
      'batch_test_ver01/data/BATCH_1.xml'
    )
  end
end
