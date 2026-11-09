import 'dart:ffi' as ffi;

class OnnxRuntimeBindings {

  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  OnnxRuntimeBindings(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  OnnxRuntimeBindings.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  ffi.Pointer<OrtApiBase> OrtGetApiBase() {
    return _OrtGetApiBase();
  }

  late final _OrtGetApiBasePtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<OrtApiBase> Function()>>(
          'OrtGetApiBase');
  late final _OrtGetApiBase =
      _OrtGetApiBasePtr.asFunction<ffi.Pointer<OrtApiBase> Function()>();

  OrtStatusPtr OrtSessionOptionsAppendExecutionProvider_CUDA(
    ffi.Pointer<OrtSessionOptions> options,
    int device_id,
  ) {
    return _OrtSessionOptionsAppendExecutionProvider_CUDA(
      options,
      device_id,
    );
  }

  late final _OrtSessionOptionsAppendExecutionProvider_CUDAPtr = _lookup<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions>,
              ffi.Int)>>('OrtSessionOptionsAppendExecutionProvider_CUDA');
  late final _OrtSessionOptionsAppendExecutionProvider_CUDA =
      _OrtSessionOptionsAppendExecutionProvider_CUDAPtr.asFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions>, int)>();

  OrtStatusPtr OrtSessionOptionsAppendExecutionProvider_MIGraphX(
    ffi.Pointer<OrtSessionOptions> options,
    int device_id,
  ) {
    return _OrtSessionOptionsAppendExecutionProvider_MIGraphX(
      options,
      device_id,
    );
  }

  late final _OrtSessionOptionsAppendExecutionProvider_MIGraphXPtr = _lookup<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions>,
              ffi.Int)>>('OrtSessionOptionsAppendExecutionProvider_MIGraphX');
  late final _OrtSessionOptionsAppendExecutionProvider_MIGraphX =
      _OrtSessionOptionsAppendExecutionProvider_MIGraphXPtr.asFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions>, int)>();

  OrtStatusPtr OrtSessionOptionsAppendExecutionProvider_Dnnl(
    ffi.Pointer<OrtSessionOptions> options,
    int use_arena,
  ) {
    return _OrtSessionOptionsAppendExecutionProvider_Dnnl(
      options,
      use_arena,
    );
  }

  late final _OrtSessionOptionsAppendExecutionProvider_DnnlPtr = _lookup<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions>,
              ffi.Int)>>('OrtSessionOptionsAppendExecutionProvider_Dnnl');
  late final _OrtSessionOptionsAppendExecutionProvider_Dnnl =
      _OrtSessionOptionsAppendExecutionProvider_DnnlPtr.asFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions>, int)>();

  OrtStatusPtr OrtSessionOptionsAppendExecutionProvider_CoreML(
    ffi.Pointer<OrtSessionOptions> options,
    int coreml_flags,
  ) {
    return _OrtSessionOptionsAppendExecutionProvider_CoreML(
      options,
      coreml_flags,
    );
  }

  late final _OrtSessionOptionsAppendExecutionProvider_CoreMLPtr = _lookup<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions>,
              ffi.Uint32)>>('OrtSessionOptionsAppendExecutionProvider_CoreML');
  late final _OrtSessionOptionsAppendExecutionProvider_CoreML =
      _OrtSessionOptionsAppendExecutionProvider_CoreMLPtr.asFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions>, int)>();

  OrtStatusPtr OrtSessionOptionsAppendExecutionProvider_CPU(
    ffi.Pointer<OrtSessionOptions> options,
    int use_arena,
  ) {
    return _OrtSessionOptionsAppendExecutionProvider_CPU(
      options,
      use_arena,
    );
  }

  late final _OrtSessionOptionsAppendExecutionProvider_CPUPtr = _lookup<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions>,
              ffi.Int)>>('OrtSessionOptionsAppendExecutionProvider_CPU');
  late final _OrtSessionOptionsAppendExecutionProvider_CPU =
      _OrtSessionOptionsAppendExecutionProvider_CPUPtr.asFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions>, int)>();

  OrtStatusPtr OrtSessionOptionsAppendExecutionProvider_Nnapi(
    ffi.Pointer<OrtSessionOptions> options,
    int nnapi_flags,
  ) {
    return _OrtSessionOptionsAppendExecutionProvider_Nnapi(
      options,
      nnapi_flags,
    );
  }

  late final _OrtSessionOptionsAppendExecutionProvider_NnapiPtr = _lookup<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions>,
              ffi.Uint32)>>('OrtSessionOptionsAppendExecutionProvider_Nnapi');
  late final _OrtSessionOptionsAppendExecutionProvider_Nnapi =
      _OrtSessionOptionsAppendExecutionProvider_NnapiPtr.asFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions>, int)>();

  late final ffi.Pointer<ffi.Int> _Ort = _lookup<ffi.Int>('Ort');

  int get Ort => _Ort.value;

  set Ort(int value) => _Ort.value = value;
}

abstract class ONNXTensorElementDataType {
  static const int ONNX_TENSOR_ELEMENT_DATA_TYPE_UNDEFINED = 0;

  static const int ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT = 1;

  static const int ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT8 = 2;

  static const int ONNX_TENSOR_ELEMENT_DATA_TYPE_INT8 = 3;

  static const int ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT16 = 4;

  static const int ONNX_TENSOR_ELEMENT_DATA_TYPE_INT16 = 5;

  static const int ONNX_TENSOR_ELEMENT_DATA_TYPE_INT32 = 6;

  static const int ONNX_TENSOR_ELEMENT_DATA_TYPE_INT64 = 7;

  static const int ONNX_TENSOR_ELEMENT_DATA_TYPE_STRING = 8;
  static const int ONNX_TENSOR_ELEMENT_DATA_TYPE_BOOL = 9;
  static const int ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT16 = 10;

  static const int ONNX_TENSOR_ELEMENT_DATA_TYPE_DOUBLE = 11;

  static const int ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT32 = 12;

  static const int ONNX_TENSOR_ELEMENT_DATA_TYPE_UINT64 = 13;

  static const int ONNX_TENSOR_ELEMENT_DATA_TYPE_COMPLEX64 = 14;

  static const int ONNX_TENSOR_ELEMENT_DATA_TYPE_COMPLEX128 = 15;

  static const int ONNX_TENSOR_ELEMENT_DATA_TYPE_BFLOAT16 = 16;
}

abstract class ONNXType {
  static const int ONNX_TYPE_UNKNOWN = 0;
  static const int ONNX_TYPE_TENSOR = 1;
  static const int ONNX_TYPE_SEQUENCE = 2;
  static const int ONNX_TYPE_MAP = 3;
  static const int ONNX_TYPE_OPAQUE = 4;
  static const int ONNX_TYPE_SPARSETENSOR = 5;
  static const int ONNX_TYPE_OPTIONAL = 6;
}

abstract class OrtSparseFormat {
  static const int ORT_SPARSE_UNDEFINED = 0;
  static const int ORT_SPARSE_COO = 1;
  static const int ORT_SPARSE_CSRC = 2;
  static const int ORT_SPARSE_BLOCK_SPARSE = 4;
}

abstract class OrtSparseIndicesFormat {
  static const int ORT_SPARSE_COO_INDICES = 0;
  static const int ORT_SPARSE_CSR_INNER_INDICES = 1;
  static const int ORT_SPARSE_CSR_OUTER_INDICES = 2;
  static const int ORT_SPARSE_BLOCK_SPARSE_INDICES = 3;
}

abstract class OrtLoggingLevel {

  static const int ORT_LOGGING_LEVEL_VERBOSE = 0;

  static const int ORT_LOGGING_LEVEL_INFO = 1;

  static const int ORT_LOGGING_LEVEL_WARNING = 2;

  static const int ORT_LOGGING_LEVEL_ERROR = 3;

  static const int ORT_LOGGING_LEVEL_FATAL = 4;
}

abstract class OrtErrorCode {
  static const int ORT_OK = 0;
  static const int ORT_FAIL = 1;
  static const int ORT_INVALID_ARGUMENT = 2;
  static const int ORT_NO_SUCHFILE = 3;
  static const int ORT_NO_MODEL = 4;
  static const int ORT_ENGINE_ERROR = 5;
  static const int ORT_RUNTIME_EXCEPTION = 6;
  static const int ORT_INVALID_PROTOBUF = 7;
  static const int ORT_MODEL_LOADED = 8;
  static const int ORT_NOT_IMPLEMENTED = 9;
  static const int ORT_INVALID_GRAPH = 10;
  static const int ORT_EP_FAIL = 11;
}

abstract class OrtOpAttrType {
  static const int ORT_OP_ATTR_UNDEFINED = 0;
  static const int ORT_OP_ATTR_INT = 1;
  static const int ORT_OP_ATTR_INTS = 2;
  static const int ORT_OP_ATTR_FLOAT = 3;
  static const int ORT_OP_ATTR_FLOATS = 4;
  static const int ORT_OP_ATTR_STRING = 5;
  static const int ORT_OP_ATTR_STRINGS = 6;
}

final class OrtEnv extends ffi.Opaque {}

final class OrtStatus extends ffi.Opaque {}

final class OrtMemoryInfo extends ffi.Opaque {}

final class OrtIoBinding extends ffi.Opaque {}

final class OrtSession extends ffi.Opaque {}

final class OrtValue extends ffi.Opaque {}

final class OrtRunOptions extends ffi.Opaque {}

final class OrtTypeInfo extends ffi.Opaque {}

final class OrtTensorTypeAndShapeInfo extends ffi.Opaque {}

final class OrtMapTypeInfo extends ffi.Opaque {}

final class OrtSequenceTypeInfo extends ffi.Opaque {}

final class OrtOptionalTypeInfo extends ffi.Opaque {}

final class OrtSessionOptions extends ffi.Opaque {}

final class OrtCustomOpDomain extends ffi.Opaque {}

final class OrtModelMetadata extends ffi.Opaque {}

final class OrtThreadPoolParams extends ffi.Opaque {}

final class OrtThreadingOptions extends ffi.Opaque {}

final class OrtArenaCfg extends ffi.Opaque {}

final class OrtPrepackedWeightsContainer extends ffi.Opaque {}

final class OrtTensorRTProviderOptionsV2 extends ffi.Opaque {}

final class OrtCUDAProviderOptionsV2 extends ffi.Opaque {}

final class OrtCANNProviderOptions extends ffi.Opaque {}

final class OrtDnnlProviderOptions extends ffi.Opaque {}

final class OrtOp extends ffi.Opaque {}

final class OrtOpAttr extends ffi.Opaque {}

final class OrtLogger extends ffi.Opaque {}

final class OrtAllocator extends ffi.Struct {

  @ffi.Uint32()
  external int version;

  external ffi.Pointer<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Void> Function(
              ffi.Pointer<OrtAllocator> this_, ffi.Size size)>> Alloc;

  external ffi.Pointer<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Pointer<OrtAllocator> this_, ffi.Pointer<ffi.Void> p)>> Free;

  external ffi.Pointer<
      ffi.NativeFunction<
          ffi.Pointer<OrtMemoryInfo> Function(
              ffi.Pointer<OrtAllocator> this_)>> Info;
}

abstract class GraphOptimizationLevel {
  static const int ORT_DISABLE_ALL = 0;
  static const int ORT_ENABLE_BASIC = 1;
  static const int ORT_ENABLE_EXTENDED = 2;
  static const int ORT_ENABLE_ALL = 99;
}

abstract class ExecutionMode {
  static const int ORT_SEQUENTIAL = 0;
  static const int ORT_PARALLEL = 1;
}

abstract class OrtLanguageProjection {
  static const int ORT_PROJECTION_C = 0;
  static const int ORT_PROJECTION_CPLUSPLUS = 1;
  static const int ORT_PROJECTION_CSHARP = 2;
  static const int ORT_PROJECTION_PYTHON = 3;
  static const int ORT_PROJECTION_JAVA = 4;
  static const int ORT_PROJECTION_WINML = 5;
  static const int ORT_PROJECTION_NODEJS = 6;
}

final class OrtKernelInfo extends ffi.Opaque {}

final class OrtKernelContext extends ffi.Opaque {}

final class OrtCustomOp extends ffi.Struct {

  @ffi.Uint32()
  external int version;

  external ffi.Pointer<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Void> Function(
              ffi.Pointer<OrtCustomOp> op,
              ffi.Pointer<OrtApi> api,
              ffi.Pointer<OrtKernelInfo> info)>> CreateKernel;

  external ffi.Pointer<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(ffi.Pointer<OrtCustomOp> op)>> GetName;

  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Pointer<ffi.Char> Function(ffi.Pointer<OrtCustomOp> op)>>
      GetExecutionProviderType;

  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Int32 Function(ffi.Pointer<OrtCustomOp> op, ffi.Size index)>>
      GetInputType;

  external ffi.Pointer<
          ffi.NativeFunction<ffi.Size Function(ffi.Pointer<OrtCustomOp> op)>>
      GetInputTypeCount;

  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Int32 Function(ffi.Pointer<OrtCustomOp> op, ffi.Size index)>>
      GetOutputType;

  external ffi.Pointer<
          ffi.NativeFunction<ffi.Size Function(ffi.Pointer<OrtCustomOp> op)>>
      GetOutputTypeCount;

  external ffi.Pointer<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<ffi.Void> op_kernel,
              ffi.Pointer<OrtKernelContext> context)>> KernelCompute;

  external ffi.Pointer<
          ffi
          .NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void> op_kernel)>>
      KernelDestroy;

  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Int32 Function(ffi.Pointer<OrtCustomOp> op, ffi.Size index)>>
      GetInputCharacteristic;

  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Int32 Function(ffi.Pointer<OrtCustomOp> op, ffi.Size index)>>
      GetOutputCharacteristic;

  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Int32 Function(ffi.Pointer<OrtCustomOp> op, ffi.Size index)>>
      GetInputMemoryType;

  external ffi.Pointer<
          ffi.NativeFunction<ffi.Int Function(ffi.Pointer<OrtCustomOp> op)>>
      GetVariadicInputMinArity;

  external ffi.Pointer<
          ffi.NativeFunction<ffi.Int Function(ffi.Pointer<OrtCustomOp> op)>>
      GetVariadicInputHomogeneity;

  external ffi.Pointer<
          ffi.NativeFunction<ffi.Int Function(ffi.Pointer<OrtCustomOp> op)>>
      GetVariadicOutputMinArity;

  external ffi.Pointer<
          ffi.NativeFunction<ffi.Int Function(ffi.Pointer<OrtCustomOp> op)>>
      GetVariadicOutputHomogeneity;
}

final class OrtApi extends ffi.Struct {

  external ffi.Pointer<
      ffi.NativeFunction<
          ffi.Pointer<OrtStatus> Function(
              ffi.Int32 code, ffi.Pointer<ffi.Char> msg)>> CreateStatus;

  external ffi.Pointer<
          ffi.NativeFunction<ffi.Int32 Function(ffi.Pointer<OrtStatus> status)>>
      GetErrorCode;

  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Pointer<ffi.Char> Function(ffi.Pointer<OrtStatus> status)>>
      GetErrorMessage;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Int32 log_severity_level,
              ffi.Pointer<ffi.Char> logid,
              ffi.Pointer<ffi.Pointer<OrtEnv>> out)>> CreateEnv;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              OrtLoggingFunction logging_function,
              ffi.Pointer<ffi.Void> logger_param,
              ffi.Int32 log_severity_level,
              ffi.Pointer<ffi.Char> logid,
              ffi.Pointer<ffi.Pointer<OrtEnv>> out)>> CreateEnvWithCustomLogger;

  external ffi.Pointer<
          ffi.NativeFunction<OrtStatusPtr Function(ffi.Pointer<OrtEnv> env)>>
      EnableTelemetryEvents;

  external ffi.Pointer<
          ffi.NativeFunction<OrtStatusPtr Function(ffi.Pointer<OrtEnv> env)>>
      DisableTelemetryEvents;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtEnv> env,
              ffi.Pointer<ffi.Char> model_path,
              ffi.Pointer<OrtSessionOptions> options,
              ffi.Pointer<ffi.Pointer<OrtSession>> out)>> CreateSession;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtEnv> env,
                  ffi.Pointer<ffi.Void> model_data,
                  ffi.Size model_data_length,
                  ffi.Pointer<OrtSessionOptions> options,
                  ffi.Pointer<ffi.Pointer<OrtSession>> out)>>
      CreateSessionFromArray;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtSession> session,
              ffi.Pointer<OrtRunOptions> run_options,
              ffi.Pointer<ffi.Pointer<ffi.Char>> input_names,
              ffi.Pointer<ffi.Pointer<OrtValue>> inputs,
              ffi.Size input_len,
              ffi.Pointer<ffi.Pointer<ffi.Char>> output_names,
              ffi.Size output_names_len,
              ffi.Pointer<ffi.Pointer<OrtValue>> outputs)>> Run;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<ffi.Pointer<OrtSessionOptions>> options)>>
      CreateSessionOptions;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options,
                  ffi.Pointer<ffi.Char> optimized_model_filepath)>>
      SetOptimizedModelFilePath;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> in_options,
                  ffi.Pointer<ffi.Pointer<OrtSessionOptions>> out_options)>>
      CloneSessionOptions;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options,
              ffi.Int32 execution_mode)>> SetSessionExecutionMode;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options,
              ffi.Pointer<ffi.Char> profile_file_prefix)>> EnableProfiling;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options)>>
      DisableProfiling;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options)>>
      EnableMemPattern;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options)>>
      DisableMemPattern;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options)>>
      EnableCpuMemArena;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options)>>
      DisableCpuMemArena;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options,
              ffi.Pointer<ffi.Char> logid)>> SetSessionLogId;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options,
                  ffi.Int session_log_verbosity_level)>>
      SetSessionLogVerbosityLevel;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options,
              ffi.Int session_log_severity_level)>> SetSessionLogSeverityLevel;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options,
                  ffi.Int32 graph_optimization_level)>>
      SetSessionGraphOptimizationLevel;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options,
              ffi.Int intra_op_num_threads)>> SetIntraOpNumThreads;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options,
              ffi.Int inter_op_num_threads)>> SetInterOpNumThreads;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<ffi.Char> domain,
                  ffi.Pointer<ffi.Pointer<OrtCustomOpDomain>> out)>>
      CreateCustomOpDomain;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtCustomOpDomain> custom_op_domain,
              ffi.Pointer<OrtCustomOp> op)>> CustomOpDomain_Add;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options,
                  ffi.Pointer<OrtCustomOpDomain> custom_op_domain)>>
      AddCustomOpDomain;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtSessionOptions> options,
                  ffi.Pointer<ffi.Char> library_path,
                  ffi.Pointer<ffi.Pointer<ffi.Void>> library_handle)>>
      RegisterCustomOpsLibrary;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtSession> session, ffi.Pointer<ffi.Size> out)>>
      SessionGetInputCount;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtSession> session, ffi.Pointer<ffi.Size> out)>>
      SessionGetOutputCount;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtSession> session, ffi.Pointer<ffi.Size> out)>>
      SessionGetOverridableInitializerCount;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtSession> session,
                  ffi.Size index,
                  ffi.Pointer<ffi.Pointer<OrtTypeInfo>> type_info)>>
      SessionGetInputTypeInfo;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtSession> session,
                  ffi.Size index,
                  ffi.Pointer<ffi.Pointer<OrtTypeInfo>> type_info)>>
      SessionGetOutputTypeInfo;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtSession> session,
                  ffi.Size index,
                  ffi.Pointer<ffi.Pointer<OrtTypeInfo>> type_info)>>
      SessionGetOverridableInitializerTypeInfo;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtSession> session,
              ffi.Size index,
              ffi.Pointer<OrtAllocator> allocator,
              ffi.Pointer<ffi.Pointer<ffi.Char>> value)>> SessionGetInputName;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtSession> session,
              ffi.Size index,
              ffi.Pointer<OrtAllocator> allocator,
              ffi.Pointer<ffi.Pointer<ffi.Char>> value)>> SessionGetOutputName;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtSession> session,
                  ffi.Size index,
                  ffi.Pointer<OrtAllocator> allocator,
                  ffi.Pointer<ffi.Pointer<ffi.Char>> value)>>
      SessionGetOverridableInitializerName;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<ffi.Pointer<OrtRunOptions>> out)>> CreateRunOptions;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtRunOptions> options,
              ffi.Int log_verbosity_level)>> RunOptionsSetRunLogVerbosityLevel;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtRunOptions> options,
              ffi.Int log_severity_level)>> RunOptionsSetRunLogSeverityLevel;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtRunOptions> options,
              ffi.Pointer<ffi.Char> run_tag)>> RunOptionsSetRunTag;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtRunOptions> options,
                  ffi.Pointer<ffi.Int> log_verbosity_level)>>
      RunOptionsGetRunLogVerbosityLevel;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtRunOptions> options,
                  ffi.Pointer<ffi.Int> log_severity_level)>>
      RunOptionsGetRunLogSeverityLevel;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtRunOptions> options,
              ffi.Pointer<ffi.Pointer<ffi.Char>> run_tag)>> RunOptionsGetRunTag;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtRunOptions> options)>>
      RunOptionsSetTerminate;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtRunOptions> options)>>
      RunOptionsUnsetTerminate;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtAllocator> allocator,
              ffi.Pointer<ffi.Int64> shape,
              ffi.Size shape_len,
              ffi.Int32 type,
              ffi.Pointer<ffi.Pointer<OrtValue>> out)>> CreateTensorAsOrtValue;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtMemoryInfo> info,
                  ffi.Pointer<ffi.Void> p_data,
                  ffi.Size p_data_len,
                  ffi.Pointer<ffi.Int64> shape,
                  ffi.Size shape_len,
                  ffi.Int32 type,
                  ffi.Pointer<ffi.Pointer<OrtValue>> out)>>
      CreateTensorWithDataAsOrtValue;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtValue> value, ffi.Pointer<ffi.Int> out)>> IsTensor;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtValue> value,
              ffi.Pointer<ffi.Pointer<ffi.Void>> out)>> GetTensorMutableData;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtValue> value,
              ffi.Pointer<ffi.Pointer<ffi.Char>> s,
              ffi.Size s_len)>> FillStringTensor;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtValue> value, ffi.Pointer<ffi.Size> len)>>
      GetStringTensorDataLength;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtValue> value,
              ffi.Pointer<ffi.Void> s,
              ffi.Size s_len,
              ffi.Pointer<ffi.Size> offsets,
              ffi.Size offsets_len)>> GetStringTensorContent;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtTypeInfo> type_info,
                  ffi.Pointer<ffi.Pointer<OrtTensorTypeAndShapeInfo>> out)>>
      CastTypeInfoToTensorInfo;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtTypeInfo> type_info,
              ffi.Pointer<ffi.Int32> out)>> GetOnnxTypeFromTypeInfo;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<ffi.Pointer<OrtTensorTypeAndShapeInfo>> out)>>
      CreateTensorTypeAndShapeInfo;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtTensorTypeAndShapeInfo> info, ffi.Int32 type)>>
      SetTensorElementType;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtTensorTypeAndShapeInfo> info,
              ffi.Pointer<ffi.Int64> dim_values,
              ffi.Size dim_count)>> SetDimensions;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtTensorTypeAndShapeInfo> info,
              ffi.Pointer<ffi.Int32> out)>> GetTensorElementType;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtTensorTypeAndShapeInfo> info,
              ffi.Pointer<ffi.Size> out)>> GetDimensionsCount;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtTensorTypeAndShapeInfo> info,
              ffi.Pointer<ffi.Int64> dim_values,
              ffi.Size dim_values_length)>> GetDimensions;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtTensorTypeAndShapeInfo> info,
              ffi.Pointer<ffi.Pointer<ffi.Char>> dim_params,
              ffi.Size dim_params_length)>> GetSymbolicDimensions;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtTensorTypeAndShapeInfo> info,
              ffi.Pointer<ffi.Size> out)>> GetTensorShapeElementCount;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtValue> value,
                  ffi.Pointer<ffi.Pointer<OrtTensorTypeAndShapeInfo>> out)>>
      GetTensorTypeAndShape;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtValue> value,
              ffi.Pointer<ffi.Pointer<OrtTypeInfo>> out)>> GetTypeInfo;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtValue> value, ffi.Pointer<ffi.Int32> out)>>
      GetValueType;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<ffi.Char> name,
              ffi.Int32 type,
              ffi.Int id,
              ffi.Int32 mem_type,
              ffi.Pointer<ffi.Pointer<OrtMemoryInfo>> out)>> CreateMemoryInfo;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Int32 type, ffi.Int32 mem_type,
                  ffi.Pointer<ffi.Pointer<OrtMemoryInfo>> out)>>
      CreateCpuMemoryInfo;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtMemoryInfo> info1,
              ffi.Pointer<OrtMemoryInfo> info2,
              ffi.Pointer<ffi.Int> out)>> CompareMemoryInfo;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtMemoryInfo> ptr,
              ffi.Pointer<ffi.Pointer<ffi.Char>> out)>> MemoryInfoGetName;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtMemoryInfo> ptr, ffi.Pointer<ffi.Int> out)>>
      MemoryInfoGetId;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtMemoryInfo> ptr, ffi.Pointer<ffi.Int32> out)>>
      MemoryInfoGetMemType;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtMemoryInfo> ptr, ffi.Pointer<ffi.Int32> out)>>
      MemoryInfoGetType;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtAllocator> ort_allocator,
              ffi.Size size,
              ffi.Pointer<ffi.Pointer<ffi.Void>> out)>> AllocatorAlloc;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtAllocator> ort_allocator,
              ffi.Pointer<ffi.Void> p)>> AllocatorFree;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtAllocator> ort_allocator,
              ffi.Pointer<ffi.Pointer<OrtMemoryInfo>> out)>> AllocatorGetInfo;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<ffi.Pointer<OrtAllocator>> out)>>
      GetAllocatorWithDefaultOptions;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtSessionOptions> options,
              ffi.Pointer<ffi.Char> dim_denotation,
              ffi.Int64 dim_value)>> AddFreeDimensionOverride;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtValue> value,
              ffi.Int index,
              ffi.Pointer<OrtAllocator> allocator,
              ffi.Pointer<ffi.Pointer<OrtValue>> out)>> GetValue;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtValue> value, ffi.Pointer<ffi.Size> out)>>
      GetValueCount;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<ffi.Pointer<OrtValue>> in1,
              ffi.Size num_values,
              ffi.Int32 value_type,
              ffi.Pointer<ffi.Pointer<OrtValue>> out)>> CreateValue;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<ffi.Char> domain_name,
              ffi.Pointer<ffi.Char> type_name,
              ffi.Pointer<ffi.Void> data_container,
              ffi.Size data_container_size,
              ffi.Pointer<ffi.Pointer<OrtValue>> out)>> CreateOpaqueValue;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<ffi.Char> domain_name,
              ffi.Pointer<ffi.Char> type_name,
              ffi.Pointer<OrtValue> in1,
              ffi.Pointer<ffi.Void> data_container,
              ffi.Size data_container_size)>> GetOpaqueValue;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtKernelInfo> info,
              ffi.Pointer<ffi.Char> name,
              ffi.Pointer<ffi.Float> out)>> KernelInfoGetAttribute_float;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtKernelInfo> info,
              ffi.Pointer<ffi.Char> name,
              ffi.Pointer<ffi.Int64> out)>> KernelInfoGetAttribute_int64;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtKernelInfo> info,
              ffi.Pointer<ffi.Char> name,
              ffi.Pointer<ffi.Char> out,
              ffi.Pointer<ffi.Size> size)>> KernelInfoGetAttribute_string;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtKernelContext> context,
              ffi.Pointer<ffi.Size> out)>> KernelContext_GetInputCount;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtKernelContext> context,
              ffi.Pointer<ffi.Size> out)>> KernelContext_GetOutputCount;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtKernelContext> context,
              ffi.Size index,
              ffi.Pointer<ffi.Pointer<OrtValue>> out)>> KernelContext_GetInput;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtKernelContext> context,
              ffi.Size index,
              ffi.Pointer<ffi.Int64> dim_values,
              ffi.Size dim_count,
              ffi.Pointer<ffi.Pointer<OrtValue>> out)>> KernelContext_GetOutput;

  external ffi
      .Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<OrtEnv> input)>>
      ReleaseEnv;

  external ffi.Pointer<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<OrtStatus> input)>>
      ReleaseStatus;

  external ffi.Pointer<
          ffi
          .NativeFunction<ffi.Void Function(ffi.Pointer<OrtMemoryInfo> input)>>
      ReleaseMemoryInfo;

  external ffi.Pointer<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<OrtSession> input)>>
      ReleaseSession;

  external ffi.Pointer<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<OrtValue> input)>>
      ReleaseValue;

  external ffi.Pointer<
          ffi
          .NativeFunction<ffi.Void Function(ffi.Pointer<OrtRunOptions> input)>>
      ReleaseRunOptions;

  external ffi.Pointer<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<OrtTypeInfo> input)>>
      ReleaseTypeInfo;

  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<OrtTensorTypeAndShapeInfo> input)>>
      ReleaseTensorTypeAndShapeInfo;

  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<OrtSessionOptions> input)>>
      ReleaseSessionOptions;

  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<OrtCustomOpDomain> input)>>
      ReleaseCustomOpDomain;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtTypeInfo> type_info,
              ffi.Pointer<ffi.Pointer<ffi.Char>> denotation,
              ffi.Pointer<ffi.Size> len)>> GetDenotationFromTypeInfo;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtTypeInfo> type_info,
                  ffi.Pointer<ffi.Pointer<OrtMapTypeInfo>> out)>>
      CastTypeInfoToMapTypeInfo;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtTypeInfo> type_info,
                  ffi.Pointer<ffi.Pointer<OrtSequenceTypeInfo>> out)>>
      CastTypeInfoToSequenceTypeInfo;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtMapTypeInfo> map_type_info,
              ffi.Pointer<ffi.Int32> out)>> GetMapKeyType;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtMapTypeInfo> map_type_info,
                  ffi.Pointer<ffi.Pointer<OrtTypeInfo>> type_info)>>
      GetMapValueType;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtSequenceTypeInfo> sequence_type_info,
                  ffi.Pointer<ffi.Pointer<OrtTypeInfo>> type_info)>>
      GetSequenceElementType;

  external ffi.Pointer<
          ffi
          .NativeFunction<ffi.Void Function(ffi.Pointer<OrtMapTypeInfo> input)>>
      ReleaseMapTypeInfo;

  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<OrtSequenceTypeInfo> input)>>
      ReleaseSequenceTypeInfo;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtSession> session,
              ffi.Pointer<OrtAllocator> allocator,
              ffi.Pointer<ffi.Pointer<ffi.Char>> out)>> SessionEndProfiling;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSession> session,
                  ffi.Pointer<ffi.Pointer<OrtModelMetadata>> out)>>
      SessionGetModelMetadata;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtModelMetadata> model_metadata,
                  ffi.Pointer<OrtAllocator> allocator,
                  ffi.Pointer<ffi.Pointer<ffi.Char>> value)>>
      ModelMetadataGetProducerName;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtModelMetadata> model_metadata,
                  ffi.Pointer<OrtAllocator> allocator,
                  ffi.Pointer<ffi.Pointer<ffi.Char>> value)>>
      ModelMetadataGetGraphName;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtModelMetadata> model_metadata,
                  ffi.Pointer<OrtAllocator> allocator,
                  ffi.Pointer<ffi.Pointer<ffi.Char>> value)>>
      ModelMetadataGetDomain;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtModelMetadata> model_metadata,
                  ffi.Pointer<OrtAllocator> allocator,
                  ffi.Pointer<ffi.Pointer<ffi.Char>> value)>>
      ModelMetadataGetDescription;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtModelMetadata> model_metadata,
                  ffi.Pointer<OrtAllocator> allocator,
                  ffi.Pointer<ffi.Char> key,
                  ffi.Pointer<ffi.Pointer<ffi.Char>> value)>>
      ModelMetadataLookupCustomMetadataMap;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtModelMetadata> model_metadata,
              ffi.Pointer<ffi.Int64> value)>> ModelMetadataGetVersion;

  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<OrtModelMetadata> input)>>
      ReleaseModelMetadata;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Int32 log_severity_level,
                  ffi.Pointer<ffi.Char> logid,
                  ffi.Pointer<OrtThreadingOptions> tp_options,
                  ffi.Pointer<ffi.Pointer<OrtEnv>> out)>>
      CreateEnvWithGlobalThreadPools;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options)>>
      DisablePerSessionThreads;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<ffi.Pointer<OrtThreadingOptions>> out)>>
      CreateThreadingOptions;

  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<OrtThreadingOptions> input)>>
      ReleaseThreadingOptions;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtModelMetadata> model_metadata,
                  ffi.Pointer<OrtAllocator> allocator,
                  ffi.Pointer<ffi.Pointer<ffi.Pointer<ffi.Char>>> keys,
                  ffi.Pointer<ffi.Int64> num_keys)>>
      ModelMetadataGetCustomMetadataMapKeys;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtSessionOptions> options,
              ffi.Pointer<ffi.Char> dim_name,
              ffi.Int64 dim_value)>> AddFreeDimensionOverrideByName;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<ffi.Pointer<ffi.Pointer<ffi.Char>>> out_ptr,
              ffi.Pointer<ffi.Int> provider_length)>> GetAvailableProviders;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<ffi.Pointer<ffi.Char>> ptr,
              ffi.Int providers_length)>> ReleaseAvailableProviders;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtValue> value, ffi.Size index,
              ffi.Pointer<ffi.Size> out)>> GetStringTensorElementLength;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtValue> value, ffi.Size s_len,
              ffi.Size index, ffi.Pointer<ffi.Void> s)>> GetStringTensorElement;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtValue> value,
              ffi.Pointer<ffi.Char> s,
              ffi.Size index)>> FillStringTensorElement;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtSessionOptions> options,
              ffi.Pointer<ffi.Char> config_key,
              ffi.Pointer<ffi.Char> config_value)>> AddSessionConfigEntry;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtSession> session,
              ffi.Pointer<OrtMemoryInfo> mem_info,
              ffi.Pointer<ffi.Pointer<OrtAllocator>> out)>> CreateAllocator;

  external ffi.Pointer<
          ffi
          .NativeFunction<ffi.Void Function(ffi.Pointer<OrtAllocator> input)>>
      ReleaseAllocator;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtSession> session,
              ffi.Pointer<OrtRunOptions> run_options,
              ffi.Pointer<OrtIoBinding> binding_ptr)>> RunWithBinding;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtSession> session,
              ffi.Pointer<ffi.Pointer<OrtIoBinding>> out)>> CreateIoBinding;

  external ffi.Pointer<
          ffi
          .NativeFunction<ffi.Void Function(ffi.Pointer<OrtIoBinding> input)>>
      ReleaseIoBinding;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtIoBinding> binding_ptr,
              ffi.Pointer<ffi.Char> name,
              ffi.Pointer<OrtValue> val_ptr)>> BindInput;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtIoBinding> binding_ptr,
              ffi.Pointer<ffi.Char> name,
              ffi.Pointer<OrtValue> val_ptr)>> BindOutput;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtIoBinding> binding_ptr,
              ffi.Pointer<ffi.Char> name,
              ffi.Pointer<OrtMemoryInfo> mem_info_ptr)>> BindOutputToDevice;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtIoBinding> binding_ptr,
              ffi.Pointer<OrtAllocator> allocator,
              ffi.Pointer<ffi.Pointer<ffi.Char>> buffer,
              ffi.Pointer<ffi.Pointer<ffi.Size>> lengths,
              ffi.Pointer<ffi.Size> count)>> GetBoundOutputNames;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtIoBinding> binding_ptr,
              ffi.Pointer<OrtAllocator> allocator,
              ffi.Pointer<ffi.Pointer<ffi.Pointer<OrtValue>>> output,
              ffi.Pointer<ffi.Size> output_count)>> GetBoundOutputValues;

  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<OrtIoBinding> binding_ptr)>>
      ClearBoundInputs;

  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<OrtIoBinding> binding_ptr)>>
      ClearBoundOutputs;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtValue> value,
              ffi.Pointer<ffi.Int64> location_values,
              ffi.Size location_values_count,
              ffi.Pointer<ffi.Pointer<ffi.Void>> out)>> TensorAt;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtEnv> env,
              ffi.Pointer<OrtMemoryInfo> mem_info,
              ffi.Pointer<OrtArenaCfg> arena_cfg)>> CreateAndRegisterAllocator;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtEnv> ort_env, ffi.Int32 projection)>>
      SetLanguageProjection;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtSession> session,
              ffi.Pointer<ffi.Uint64> out)>> SessionGetProfilingStartTimeNs;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtThreadingOptions> tp_options,
              ffi.Int intra_op_num_threads)>> SetGlobalIntraOpNumThreads;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtThreadingOptions> tp_options,
              ffi.Int inter_op_num_threads)>> SetGlobalInterOpNumThreads;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtThreadingOptions> tp_options,
              ffi.Int allow_spinning)>> SetGlobalSpinControl;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtSessionOptions> options,
              ffi.Pointer<ffi.Char> name,
              ffi.Pointer<OrtValue> val)>> AddInitializer;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  OrtLoggingFunction logging_function,
                  ffi.Pointer<ffi.Void> logger_param,
                  ffi.Int32 log_severity_level,
                  ffi.Pointer<ffi.Char> logid,
                  ffi.Pointer<OrtThreadingOptions> tp_options,
                  ffi.Pointer<ffi.Pointer<OrtEnv>> out)>>
      CreateEnvWithCustomLoggerAndGlobalThreadPools;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options,
                  ffi.Pointer<OrtCUDAProviderOptions> cuda_options)>>
      SessionOptionsAppendExecutionProvider_CUDA;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options,
                  ffi.Pointer<OrtROCMProviderOptions> rocm_options)>>
      SessionOptionsAppendExecutionProvider_ROCM;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options,
                  ffi.Pointer<OrtOpenVINOProviderOptions> provider_options)>>
      SessionOptionsAppendExecutionProvider_OpenVINO;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtThreadingOptions> tp_options)>>
      SetGlobalDenormalAsZero;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Size max_mem,
              ffi.Int arena_extend_strategy,
              ffi.Int initial_chunk_size_bytes,
              ffi.Int max_dead_bytes_per_chunk,
              ffi.Pointer<ffi.Pointer<OrtArenaCfg>> out)>> CreateArenaCfg;

  external ffi.Pointer<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<OrtArenaCfg> input)>>
      ReleaseArenaCfg;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtModelMetadata> model_metadata,
                  ffi.Pointer<OrtAllocator> allocator,
                  ffi.Pointer<ffi.Pointer<ffi.Char>> value)>>
      ModelMetadataGetGraphDescription;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options,
                  ffi.Pointer<OrtTensorRTProviderOptions> tensorrt_options)>>
      SessionOptionsAppendExecutionProvider_TensorRT;

  external ffi
      .Pointer<ffi.NativeFunction<OrtStatusPtr Function(ffi.Int device_id)>>
      SetCurrentGpuDeviceId;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<ffi.Int> device_id)>>
      GetCurrentGpuDeviceId;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtKernelInfo> info,
              ffi.Pointer<ffi.Char> name,
              ffi.Pointer<ffi.Float> out,
              ffi.Pointer<ffi.Size> size)>> KernelInfoGetAttributeArray_float;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtKernelInfo> info,
              ffi.Pointer<ffi.Char> name,
              ffi.Pointer<ffi.Int64> out,
              ffi.Pointer<ffi.Size> size)>> KernelInfoGetAttributeArray_int64;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<ffi.Pointer<ffi.Char>> arena_config_keys,
              ffi.Pointer<ffi.Size> arena_config_values,
              ffi.Size num_keys,
              ffi.Pointer<ffi.Pointer<OrtArenaCfg>> out)>> CreateArenaCfgV2;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtRunOptions> options,
              ffi.Pointer<ffi.Char> config_key,
              ffi.Pointer<ffi.Char> config_value)>> AddRunConfigEntry;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<ffi.Pointer<OrtPrepackedWeightsContainer>> out)>>
      CreatePrepackedWeightsContainer;

  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Void Function(
                  ffi.Pointer<OrtPrepackedWeightsContainer> input)>>
      ReleasePrepackedWeightsContainer;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtEnv> env,
                  ffi.Pointer<ffi.Char> model_path,
                  ffi.Pointer<OrtSessionOptions> options,
                  ffi.Pointer<OrtPrepackedWeightsContainer>
                      prepacked_weights_container,
                  ffi.Pointer<ffi.Pointer<OrtSession>> out)>>
      CreateSessionWithPrepackedWeightsContainer;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtEnv> env,
                  ffi.Pointer<ffi.Void> model_data,
                  ffi.Size model_data_length,
                  ffi.Pointer<OrtSessionOptions> options,
                  ffi.Pointer<OrtPrepackedWeightsContainer>
                      prepacked_weights_container,
                  ffi.Pointer<ffi.Pointer<OrtSession>> out)>>
      CreateSessionFromArrayWithPrepackedWeightsContainer;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options,
                  ffi.Pointer<OrtTensorRTProviderOptionsV2> tensorrt_options)>>
      SessionOptionsAppendExecutionProvider_TensorRT_V2;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<ffi.Pointer<OrtTensorRTProviderOptionsV2>> out)>>
      CreateTensorRTProviderOptions;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtTensorRTProviderOptionsV2> tensorrt_options,
              ffi.Pointer<ffi.Pointer<ffi.Char>> provider_options_keys,
              ffi.Pointer<ffi.Pointer<ffi.Char>> provider_options_values,
              ffi.Size num_keys)>> UpdateTensorRTProviderOptions;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtTensorRTProviderOptionsV2> tensorrt_options,
                  ffi.Pointer<OrtAllocator> allocator,
                  ffi.Pointer<ffi.Pointer<ffi.Char>> ptr)>>
      GetTensorRTProviderOptionsAsString;

  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Void Function(
                  ffi.Pointer<OrtTensorRTProviderOptionsV2> input)>>
      ReleaseTensorRTProviderOptions;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options)>>
      EnableOrtCustomOps;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtEnv> env,
              ffi.Pointer<OrtAllocator> allocator)>> RegisterAllocator;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtEnv> env,
              ffi.Pointer<OrtMemoryInfo> mem_info)>> UnregisterAllocator;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtValue> value, ffi.Pointer<ffi.Int> out)>>
      IsSparseTensor;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtAllocator> allocator,
                  ffi.Pointer<ffi.Int64> dense_shape,
                  ffi.Size dense_shape_len,
                  ffi.Int32 type,
                  ffi.Pointer<ffi.Pointer<OrtValue>> out)>>
      CreateSparseTensorAsOrtValue;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtValue> ort_value,
              ffi.Pointer<OrtMemoryInfo> data_mem_info,
              ffi.Pointer<ffi.Int64> values_shape,
              ffi.Size values_shape_len,
              ffi.Pointer<ffi.Void> values,
              ffi.Pointer<ffi.Int64> indices_data,
              ffi.Size indices_num)>> FillSparseTensorCoo;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtValue> ort_value,
              ffi.Pointer<OrtMemoryInfo> data_mem_info,
              ffi.Pointer<ffi.Int64> values_shape,
              ffi.Size values_shape_len,
              ffi.Pointer<ffi.Void> values,
              ffi.Pointer<ffi.Int64> inner_indices_data,
              ffi.Size inner_indices_num,
              ffi.Pointer<ffi.Int64> outer_indices_data,
              ffi.Size outer_indices_num)>> FillSparseTensorCsr;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtValue> ort_value,
                  ffi.Pointer<OrtMemoryInfo> data_mem_info,
                  ffi.Pointer<ffi.Int64> values_shape,
                  ffi.Size values_shape_len,
                  ffi.Pointer<ffi.Void> values,
                  ffi.Pointer<ffi.Int64> indices_shape_data,
                  ffi.Size indices_shape_len,
                  ffi.Pointer<ffi.Int32> indices_data)>>
      FillSparseTensorBlockSparse;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtMemoryInfo> info,
                  ffi.Pointer<ffi.Void> p_data,
                  ffi.Pointer<ffi.Int64> dense_shape,
                  ffi.Size dense_shape_len,
                  ffi.Pointer<ffi.Int64> values_shape,
                  ffi.Size values_shape_len,
                  ffi.Int32 type,
                  ffi.Pointer<ffi.Pointer<OrtValue>> out)>>
      CreateSparseTensorWithValuesAsOrtValue;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtValue> ort_value,
              ffi.Pointer<ffi.Int64> indices_data,
              ffi.Size indices_num)>> UseCooIndices;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtValue> ort_value,
              ffi.Pointer<ffi.Int64> inner_data,
              ffi.Size inner_num,
              ffi.Pointer<ffi.Int64> outer_data,
              ffi.Size outer_num)>> UseCsrIndices;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtValue> ort_value,
              ffi.Pointer<ffi.Int64> indices_shape,
              ffi.Size indices_shape_len,
              ffi.Pointer<ffi.Int32> indices_data)>> UseBlockSparseIndices;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtValue> ort_value, ffi.Pointer<ffi.Int32> out)>>
      GetSparseTensorFormat;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtValue> ort_value,
                  ffi.Pointer<ffi.Pointer<OrtTensorTypeAndShapeInfo>> out)>>
      GetSparseTensorValuesTypeAndShape;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtValue> ort_value,
              ffi.Pointer<ffi.Pointer<ffi.Void>> out)>> GetSparseTensorValues;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtValue> ort_value,
                  ffi.Int32 indices_format,
                  ffi.Pointer<ffi.Pointer<OrtTensorTypeAndShapeInfo>> out)>>
      GetSparseTensorIndicesTypeShape;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtValue> ort_value,
                  ffi.Int32 indices_format,
                  ffi.Pointer<ffi.Size> num_indices,
                  ffi.Pointer<ffi.Pointer<ffi.Void>> indices)>>
      GetSparseTensorIndices;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtValue> value, ffi.Pointer<ffi.Int> out)>> HasValue;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtKernelContext> context,
                  ffi.Pointer<ffi.Pointer<ffi.Void>> out)>>
      KernelContext_GetGPUComputeStream;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtValue> value,
                  ffi.Pointer<ffi.Pointer<OrtMemoryInfo>> mem_info)>>
      GetTensorMemoryInfo;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<ffi.Char> provider_name,
                  ffi.Uint32 version,
                  ffi.Pointer<ffi.Pointer<ffi.Void>> provider_api)>>
      GetExecutionProviderApi;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options,
                  OrtCustomCreateThreadFn ort_custom_create_thread_fn)>>
      SessionOptionsSetCustomCreateThreadFn;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options,
                  ffi.Pointer<ffi.Void> ort_custom_thread_creation_options)>>
      SessionOptionsSetCustomThreadCreationOptions;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options,
                  OrtCustomJoinThreadFn ort_custom_join_thread_fn)>>
      SessionOptionsSetCustomJoinThreadFn;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtThreadingOptions> tp_options,
                  OrtCustomCreateThreadFn ort_custom_create_thread_fn)>>
      SetGlobalCustomCreateThreadFn;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtThreadingOptions> tp_options,
                  ffi.Pointer<ffi.Void> ort_custom_thread_creation_options)>>
      SetGlobalCustomThreadCreationOptions;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtThreadingOptions> tp_options,
                  OrtCustomJoinThreadFn ort_custom_join_thread_fn)>>
      SetGlobalCustomJoinThreadFn;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtIoBinding> binding_ptr)>>
      SynchronizeBoundInputs;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtIoBinding> binding_ptr)>>
      SynchronizeBoundOutputs;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options,
                  ffi.Pointer<OrtCUDAProviderOptionsV2> cuda_options)>>
      SessionOptionsAppendExecutionProvider_CUDA_V2;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<ffi.Pointer<OrtCUDAProviderOptionsV2>> out)>>
      CreateCUDAProviderOptions;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtCUDAProviderOptionsV2> cuda_options,
              ffi.Pointer<ffi.Pointer<ffi.Char>> provider_options_keys,
              ffi.Pointer<ffi.Pointer<ffi.Char>> provider_options_values,
              ffi.Size num_keys)>> UpdateCUDAProviderOptions;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtCUDAProviderOptionsV2> cuda_options,
                  ffi.Pointer<OrtAllocator> allocator,
                  ffi.Pointer<ffi.Pointer<ffi.Char>> ptr)>>
      GetCUDAProviderOptionsAsString;

  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<OrtCUDAProviderOptionsV2> input)>>
      ReleaseCUDAProviderOptions;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options,
                  ffi.Pointer<OrtMIGraphXProviderOptions> migraphx_options)>>
      SessionOptionsAppendExecutionProvider_MIGraphX;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtSessionOptions> options,
              ffi.Pointer<ffi.Pointer<ffi.Char>> initializer_names,
              ffi.Pointer<ffi.Pointer<OrtValue>> initializers,
              ffi.Size initializers_num)>> AddExternalInitializers;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<ffi.Char> name,
              ffi.Pointer<ffi.Void> data,
              ffi.Int len,
              ffi.Int32 type,
              ffi.Pointer<ffi.Pointer<OrtOpAttr>> op_attr)>> CreateOpAttr;

  external ffi.Pointer<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<OrtOpAttr> input)>>
      ReleaseOpAttr;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtKernelInfo> info,
              ffi.Pointer<ffi.Char> op_name,
              ffi.Pointer<ffi.Char> domain,
              ffi.Int version,
              ffi.Pointer<ffi.Pointer<ffi.Char>> type_constraint_names,
              ffi.Pointer<ffi.Int32> type_constraint_values,
              ffi.Int type_constraint_count,
              ffi.Pointer<ffi.Pointer<OrtOpAttr>> attr_values,
              ffi.Int attr_count,
              ffi.Int input_count,
              ffi.Int output_count,
              ffi.Pointer<ffi.Pointer<OrtOp>> ort_op)>> CreateOp;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtKernelContext> context,
              ffi.Pointer<OrtOp> ort_op,
              ffi.Pointer<ffi.Pointer<OrtValue>> input_values,
              ffi.Int input_count,
              ffi.Pointer<ffi.Pointer<OrtValue>> output_values,
              ffi.Int output_count)>> InvokeOp;

  external ffi
      .Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<OrtOp> input)>>
      ReleaseOp;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtSessionOptions> options,
              ffi.Pointer<ffi.Char> provider_name,
              ffi.Pointer<ffi.Pointer<ffi.Char>> provider_options_keys,
              ffi.Pointer<ffi.Pointer<ffi.Char>> provider_options_values,
              ffi.Size num_keys)>> SessionOptionsAppendExecutionProvider;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtKernelInfo> info,
                  ffi.Pointer<ffi.Pointer<OrtKernelInfo>> info_copy)>>
      CopyKernelInfo;

  external ffi.Pointer<
          ffi
          .NativeFunction<ffi.Void Function(ffi.Pointer<OrtKernelInfo> input)>>
      ReleaseKernelInfo;

  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Pointer<OrtTrainingApi> Function(ffi.Uint32 version)>>
      GetTrainingApi;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options,
                  ffi.Pointer<OrtCANNProviderOptions> cann_options)>>
      SessionOptionsAppendExecutionProvider_CANN;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<ffi.Pointer<OrtCANNProviderOptions>> out)>>
      CreateCANNProviderOptions;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtCANNProviderOptions> cann_options,
              ffi.Pointer<ffi.Pointer<ffi.Char>> provider_options_keys,
              ffi.Pointer<ffi.Pointer<ffi.Char>> provider_options_values,
              ffi.Size num_keys)>> UpdateCANNProviderOptions;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtCANNProviderOptions> cann_options,
                  ffi.Pointer<OrtAllocator> allocator,
                  ffi.Pointer<ffi.Pointer<ffi.Char>> ptr)>>
      GetCANNProviderOptionsAsString;

  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<OrtCANNProviderOptions> input)>>
      ReleaseCANNProviderOptions;

  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Void Function(
                  ffi.Pointer<OrtMemoryInfo> ptr, ffi.Pointer<ffi.Int32> out)>>
      MemoryInfoGetDeviceType;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtEnv> ort_env, ffi.Int32 log_severity_level)>>
      UpdateEnvWithCustomLogLevel;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtThreadingOptions> tp_options,
                  ffi.Pointer<ffi.Char> affinity_string)>>
      SetGlobalIntraOpThreadAffinity;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options,
              ffi.Pointer<ffi.Char> library_name)>> RegisterCustomOpsLibrary_V2;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options,
                  ffi.Pointer<ffi.Char> registration_func_name)>>
      RegisterCustomOpsUsingFunction;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtKernelInfo> info, ffi.Pointer<ffi.Size> out)>>
      KernelInfo_GetInputCount;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtKernelInfo> info, ffi.Pointer<ffi.Size> out)>>
      KernelInfo_GetOutputCount;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtKernelInfo> info,
              ffi.Size index,
              ffi.Pointer<ffi.Char> out,
              ffi.Pointer<ffi.Size> size)>> KernelInfo_GetInputName;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtKernelInfo> info,
              ffi.Size index,
              ffi.Pointer<ffi.Char> out,
              ffi.Pointer<ffi.Size> size)>> KernelInfo_GetOutputName;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtKernelInfo> info,
                  ffi.Size index,
                  ffi.Pointer<ffi.Pointer<OrtTypeInfo>> type_info)>>
      KernelInfo_GetInputTypeInfo;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtKernelInfo> info,
                  ffi.Size index,
                  ffi.Pointer<ffi.Pointer<OrtTypeInfo>> type_info)>>
      KernelInfo_GetOutputTypeInfo;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtKernelInfo> info,
                  ffi.Pointer<ffi.Char> name,
                  ffi.Pointer<OrtAllocator> allocator,
                  ffi.Pointer<ffi.Pointer<OrtValue>> out)>>
      KernelInfoGetAttribute_tensor;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtSessionOptions> options,
              ffi.Pointer<ffi.Char> config_key,
              ffi.Pointer<ffi.Int> out)>> HasSessionConfigEntry;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtSessionOptions> options,
              ffi.Pointer<ffi.Char> config_key,
              ffi.Pointer<ffi.Char> config_value,
              ffi.Pointer<ffi.Size> size)>> GetSessionConfigEntry;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtSessionOptions> options,
                  ffi.Pointer<OrtDnnlProviderOptions> dnnl_options)>>
      SessionOptionsAppendExecutionProvider_Dnnl;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<ffi.Pointer<OrtDnnlProviderOptions>> out)>>
      CreateDnnlProviderOptions;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtDnnlProviderOptions> dnnl_options,
              ffi.Pointer<ffi.Pointer<ffi.Char>> provider_options_keys,
              ffi.Pointer<ffi.Pointer<ffi.Char>> provider_options_values,
              ffi.Size num_keys)>> UpdateDnnlProviderOptions;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtDnnlProviderOptions> dnnl_options,
                  ffi.Pointer<OrtAllocator> allocator,
                  ffi.Pointer<ffi.Pointer<ffi.Char>> ptr)>>
      GetDnnlProviderOptionsAsString;

  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<OrtDnnlProviderOptions> input)>>
      ReleaseDnnlProviderOptions;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtKernelInfo> info,
              ffi.Pointer<ffi.Char> out,
              ffi.Pointer<ffi.Size> size)>> KernelInfo_GetNodeName;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtKernelInfo> info,
                  ffi.Pointer<ffi.Pointer<OrtLogger>> logger)>>
      KernelInfo_GetLogger;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtKernelContext> context,
                  ffi.Pointer<ffi.Pointer<OrtLogger>> logger)>>
      KernelContext_GetLogger;

  external ffi.Pointer<
      ffi.NativeFunction<
          OrtStatusPtr Function(
              ffi.Pointer<OrtLogger> logger,
              ffi.Int32 log_severity_level,
              ffi.Pointer<ffi.Char> message,
              ffi.Pointer<ffi.Char> file_path,
              ffi.Int line_number,
              ffi.Pointer<ffi.Char> func_name)>> Logger_LogMessage;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtLogger> logger, ffi.Pointer<ffi.Int32> out)>>
      Logger_GetLoggingSeverityLevel;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtKernelInfo> info,
                  ffi.Size index,
                  ffi.Pointer<ffi.Int> is_constant,
                  ffi.Pointer<ffi.Pointer<OrtValue>> out)>>
      KernelInfoGetConstantInput_tensor;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(ffi.Pointer<OrtTypeInfo> type_info,
                  ffi.Pointer<ffi.Pointer<OrtOptionalTypeInfo>> out)>>
      CastTypeInfoToOptionalTypeInfo;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtOptionalTypeInfo> optional_type_info,
                  ffi.Pointer<ffi.Pointer<OrtTypeInfo>> out)>>
      GetOptionalContainedTypeInfo;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtValue> value,
                  ffi.Size index,
                  ffi.Size length_in_bytes,
                  ffi.Pointer<ffi.Pointer<ffi.Char>> buffer)>>
      GetResizedStringTensorElementBuffer;

  external ffi.Pointer<
          ffi.NativeFunction<
              OrtStatusPtr Function(
                  ffi.Pointer<OrtKernelContext> context,
                  ffi.Pointer<OrtMemoryInfo> mem_info,
                  ffi.Pointer<ffi.Pointer<OrtAllocator>> out)>>
      KernelContext_GetAllocator;

  external ffi.Pointer<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>
      GetBuildInfoString;
}

typedef OrtStatusPtr = ffi.Pointer<OrtStatus>;
typedef OrtLoggingFunction = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Void Function(
            ffi.Pointer<ffi.Void> param,
            ffi.Int32 severity,
            ffi.Pointer<ffi.Char> category,
            ffi.Pointer<ffi.Char> logid,
            ffi.Pointer<ffi.Char> code_location,
            ffi.Pointer<ffi.Char> message)>>;

abstract class OrtAllocatorType {
  static const int OrtInvalidAllocator = -1;
  static const int OrtDeviceAllocator = 0;
  static const int OrtArenaAllocator = 1;
}

abstract class OrtMemType {

  static const int OrtMemTypeCPUInput = -2;

  static const int OrtMemTypeCPUOutput = -1;

  static const int OrtMemTypeCPU = -1;

  static const int OrtMemTypeDefault = 0;
}

final class OrtCUDAProviderOptions extends ffi.Struct {

  @ffi.Int()
  external int device_id;

  @ffi.Int32()
  external int cudnn_conv_algo_search;

  @ffi.Size()
  external int gpu_mem_limit;

  @ffi.Int()
  external int arena_extend_strategy;

  @ffi.Int()
  external int do_copy_in_default_stream;

  @ffi.Int()
  external int has_user_compute_stream;

  external ffi.Pointer<ffi.Void> user_compute_stream;

  external ffi.Pointer<OrtArenaCfg> default_memory_arena_cfg;

  @ffi.Int()
  external int tunable_op_enable;

  @ffi.Int()
  external int tunable_op_tuning_enable;
}

abstract class OrtCudnnConvAlgoSearch {

  static const int OrtCudnnConvAlgoSearchExhaustive = 0;

  static const int OrtCudnnConvAlgoSearchHeuristic = 1;

  static const int OrtCudnnConvAlgoSearchDefault = 2;
}

final class OrtROCMProviderOptions extends ffi.Struct {

  @ffi.Int()
  external int device_id;

  @ffi.Int()
  external int miopen_conv_exhaustive_search;

  @ffi.Size()
  external int gpu_mem_limit;

  @ffi.Int()
  external int arena_extend_strategy;

  @ffi.Int()
  external int do_copy_in_default_stream;

  @ffi.Int()
  external int has_user_compute_stream;

  external ffi.Pointer<ffi.Void> user_compute_stream;

  external ffi.Pointer<OrtArenaCfg> default_memory_arena_cfg;

  @ffi.Int()
  external int tunable_op_enable;

  @ffi.Int()
  external int tunable_op_tuning_enable;
}

final class OrtOpenVINOProviderOptions extends ffi.Struct {

  external ffi.Pointer<ffi.Char> device_type;

  @ffi.UnsignedChar()
  external int enable_vpu_fast_compile;

  external ffi.Pointer<ffi.Char> device_id;

  @ffi.Size()
  external int num_of_threads;

  external ffi.Pointer<ffi.Char> cache_dir;

  external ffi.Pointer<ffi.Void> context;

  @ffi.UnsignedChar()
  external int enable_opencl_throttling;

  @ffi.UnsignedChar()
  external int enable_dynamic_shapes;
}

final class OrtTensorRTProviderOptions extends ffi.Struct {

  @ffi.Int()
  external int device_id;

  @ffi.Int()
  external int has_user_compute_stream;

  external ffi.Pointer<ffi.Void> user_compute_stream;

  @ffi.Int()
  external int trt_max_partition_iterations;

  @ffi.Int()
  external int trt_min_subgraph_size;

  @ffi.Size()
  external int trt_max_workspace_size;

  @ffi.Int()
  external int trt_fp16_enable;

  @ffi.Int()
  external int trt_int8_enable;

  external ffi.Pointer<ffi.Char> trt_int8_calibration_table_name;

  @ffi.Int()
  external int trt_int8_use_native_calibration_table;

  @ffi.Int()
  external int trt_dla_enable;

  @ffi.Int()
  external int trt_dla_core;

  @ffi.Int()
  external int trt_dump_subgraphs;

  @ffi.Int()
  external int trt_engine_cache_enable;

  external ffi.Pointer<ffi.Char> trt_engine_cache_path;

  @ffi.Int()
  external int trt_engine_decryption_enable;

  external ffi.Pointer<ffi.Char> trt_engine_decryption_lib_path;

  @ffi.Int()
  external int trt_force_sequential_engine_build;
}

typedef OrtCustomCreateThreadFn = ffi.Pointer<
    ffi.NativeFunction<
        OrtCustomThreadHandle Function(
            ffi.Pointer<ffi.Void> ort_custom_thread_creation_options,
            OrtThreadWorkerFn ort_thread_worker_fn,
            ffi.Pointer<ffi.Void> ort_worker_fn_param)>>;
typedef OrtCustomThreadHandle = ffi.Pointer<OrtCustomHandleType>;

final class OrtCustomHandleType extends ffi.Struct {
  @ffi.Char()

  external int __place_holder;
}

typedef OrtThreadWorkerFn = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Void Function(ffi.Pointer<ffi.Void> ort_worker_fn_param)>>;

typedef OrtCustomJoinThreadFn = ffi.Pointer<
    ffi.NativeFunction<
        ffi.Void Function(OrtCustomThreadHandle ort_custom_thread_handle)>>;

final class OrtMIGraphXProviderOptions extends ffi.Struct {

  @ffi.Int()
  external int device_id;

  @ffi.Int()
  external int migraphx_fp16_enable;

  @ffi.Int()
  external int migraphx_int8_enable;
}

final class OrtTrainingApi extends ffi.Opaque {}

abstract class OrtMemoryInfoDeviceType {
  static const int OrtMemoryInfoDeviceType_CPU = 0;
  static const int OrtMemoryInfoDeviceType_GPU = 1;
  static const int OrtMemoryInfoDeviceType_FPGA = 2;
}

abstract class OrtCustomOpInputOutputCharacteristic {
  static const int INPUT_OUTPUT_REQUIRED = 0;
  static const int INPUT_OUTPUT_OPTIONAL = 1;
  static const int INPUT_OUTPUT_VARIADIC = 2;
}

final class OrtApiBase extends ffi.Struct {

  external ffi.Pointer<
          ffi.NativeFunction<ffi.Pointer<OrtApi> Function(ffi.Uint32 version)>>
      GetApi;

  external ffi.Pointer<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>
      GetVersionString;
}

abstract class COREMLFlags {
  static const int COREML_FLAG_USE_NONE = 0;

  static const int COREML_FLAG_USE_CPU_ONLY = 1;

  static const int COREML_FLAG_ENABLE_ON_SUBGRAPH = 2;

  static const int COREML_FLAG_ONLY_ENABLE_DEVICE_WITH_ANE = 4;

  static const int COREML_FLAG_LAST = 4;
}

abstract class NNAPIFlags {
  static const int NNAPI_FLAG_USE_NONE = 0;

  static const int NNAPI_FLAG_USE_FP16 = 1;

  static const int NNAPI_FLAG_USE_NCHW = 2;

  static const int NNAPI_FLAG_CPU_DISABLED = 4;

  static const int NNAPI_FLAG_CPU_ONLY = 8;

  static const int NNAPI_FLAG_LAST = 8;
}

const int ORT_API_VERSION = 15;

const String ORT_FILE =
    '/var/folders/s5/g1rm2nbs4v9btc3plv_ry7v00000gn/T/aJaMto/temp_for_macros.hpp';
