ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/intel/dldt/inference-engine/lib/intel64:/opt/intel/dldt/inference-engine/external/omp/lib:/usr/lib64/gstreamer-1.0:/usr/local/lib:${libdir}
ENV InferenceEngine_DIR=/opt/intel/dldt/inference-engine/share
ENV OpenCV_DIR=/opt/intel/dldt/inference-engine/external/opencv/cmake
ENV LIBRARY_PATH=/usr/lib:${LIBRARY_PATH}
ENV GST_PLUGIN_PATH=/usr/lib64/gstreamer-1.0
