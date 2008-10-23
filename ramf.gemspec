

Gem::Specification.new do |s|
  s.name = "ramf"
  s.version = "0.1.0"


  s.authors = ["Neer Friedman"]
  s.date = "2008-10-21"
  s.email = "neerfri@gmail.com"
  s.extra_rdoc_files = ["README"]
  s.files = ["lib/ramf", "lib/ramf/operation_processors_manager.rb", "lib/ramf/io", "lib/ramf/io/reference_table.rb", "lib/ramf/io/flex_class_signature.rb", "lib/ramf/io/common_read_write.rb", "lib/ramf/io/place_holder.rb", "lib/ramf/io/constants.rb", "lib/ramf/serializer.rb", "lib/ramf/amf_header.rb", "lib/ramf/configuration.rb", "lib/ramf/amf_message.rb", "lib/ramf/util.rb", "lib/ramf/operation_request.rb", "lib/ramf/flex_class_traits.rb", "lib/ramf/deserializer.rb", "lib/ramf/default_operation_processor.rb", "lib/ramf/extensions", "lib/ramf/extensions/object.rb", "lib/ramf/extensions/exception.rb", "lib/ramf/extensions/class.rb", "lib/ramf/extensions/hash.rb", "lib/ramf/deserializer", "lib/ramf/deserializer/amf3_reader.rb", "lib/ramf/deserializer/amf0_reader.rb", "lib/ramf/deserializer/base.rb", "lib/ramf/serializer", "lib/ramf/serializer/base.rb", "lib/ramf/serializer/amf3_writer.rb", "lib/ramf/serializer/amf0_writer.rb", "lib/ramf/flex_objects", "lib/ramf/flex_objects/flex_anonymous_object.rb", "lib/ramf/flex_objects/command_message.rb", "lib/ramf/flex_objects/byte_array.rb", "lib/ramf/flex_objects/remoting_message.rb", "lib/ramf/flex_objects/flex_object.rb", "lib/ramf/flex_objects/error_message.rb", "lib/ramf/flex_objects/acknowledge_message.rb", "lib/ramf/amf_object.rb", "lib/ramf.rb", "Rakefile", "LICENSE", "README", "spec/io", "spec/io/reference_table_spec.rb", "spec/spec_helper.rb", "spec/deserializer_spec.rb", "spec/flex_class_traits_spec.rb", "spec/inherited_class_traits_spec.rb", "spec/operation_processors_manager_spec.rb", "spec/examples", "spec/examples/examples_helper.rb", "spec/examples/simple_amf_spec.rb", "spec/examples/simple_remoting_spec.rb", "spec/examples/remoting_login_spec.rb", "spec/amf_object_spec.rb", "spec/fixtures", "spec/fixtures/catalog.yml", "spec/fixtures/deserializer3.bin", "spec/fixtures/ping_command_message.amf", "spec/fixtures/deserializer1.bin", "spec/fixtures/simple_remoting_message.amf", "spec/fixtures/deserializer1.rb", "spec/fixtures/deserializer2.bin", "spec/fixtures/remoting_login_operation.amf", "spec/fixtures/deserializer2.rb", "spec/extensions", "spec/extensions/class_extensions_spec.rb", "spec/serializer", "spec/serializer/full_spec.rb", "spec/serializer/amf3_writer_spec.rb", "spec/serializer/base_spec.rb"]
  s.has_rdoc = true
  s.homepage = "http://ramf.saveanalien.com"
  s.rdoc_options = ["--line-numbers", "--inline-source"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.3.0"
  s.summary = "An AMF serializer/deserializer for ruby"
  s.test_files = ["spec/io", "spec/io/reference_table_spec.rb", "spec/spec_helper.rb", "spec/deserializer_spec.rb", "spec/flex_class_traits_spec.rb", "spec/inherited_class_traits_spec.rb", "spec/operation_processors_manager_spec.rb", "spec/examples", "spec/examples/examples_helper.rb", "spec/examples/simple_amf_spec.rb", "spec/examples/simple_remoting_spec.rb", "spec/examples/remoting_login_spec.rb", "spec/amf_object_spec.rb", "spec/fixtures", "spec/fixtures/catalog.yml", "spec/fixtures/deserializer3.bin", "spec/fixtures/ping_command_message.amf", "spec/fixtures/deserializer1.bin", "spec/fixtures/simple_remoting_message.amf", "spec/fixtures/deserializer1.rb", "spec/fixtures/deserializer2.bin", "spec/fixtures/remoting_login_operation.amf", "spec/fixtures/deserializer2.rb", "spec/extensions", "spec/extensions/class_extensions_spec.rb", "spec/serializer", "spec/serializer/full_spec.rb", "spec/serializer/amf3_writer_spec.rb", "spec/serializer/base_spec.rb"]


end
