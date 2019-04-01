module Prometheus
  module Controller

    # Create a default Prometheus registry for our metrics.
    prometheus = Prometheus::Client.registry

    DELETE_COUNTER = Prometheus::Client::Histogram.new(:deleteCount,'delete counter')
    INSERT_COUNTER = Prometheus::Client::Histogram.new(:insertCount,'insert counter')
    FAILED_COUNTER = Prometheus::Client::Histogram.new(:failedCount,'failed insert counter')

    UPDATETHRESHOLD_COUNTER = Prometheus::Client::Histogram.new(:updateThresholdCount,'update threshold counter')

    SEND_CORTABOT_COUNTER = Prometheus::Client::Histogram.new(:cortabotCount,'send cortabot counter')
    LOWER_THRESHOLD = Prometheus::Client::Histogram.new(:lowerCount,'lower counter')
    UPPER_THRESHOLD = Prometheus::Client::Histogram.new(:upperCount,'upper counter')
    DIDALAM_THRESHOLD = Prometheus::Client::Histogram.new(:innerCount,'inner counter')

    THREAD_COUNTER = Prometheus::Client::Histogram.new(:threadCount, 'thread counter')
    # Register GAUGE_EXAMPLE with the registry we previously created.
    prometheus.register(THREAD_COUNTER)
    prometheus.register(DELETE_COUNTER)
    prometheus.register(INSERT_COUNTER)
    prometheus.register(FAILED_COUNTER)
    prometheus.register(UPDATETHRESHOLD_COUNTER)
    prometheus.register(SEND_CORTABOT_COUNTER)
    prometheus.register(LOWER_THRESHOLD)
    prometheus.register(UPPER_THRESHOLD)
    prometheus.register(DIDALAM_THRESHOLD)

  end
end
