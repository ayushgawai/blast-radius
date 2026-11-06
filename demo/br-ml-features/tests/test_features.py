from features.build import event_type_counts, feature_matrix, user_aggregates


def test_load_events(events):
    assert len(events) == 10_000


def test_event_type_counts(events):
    counts = event_type_counts(events)
    assert set(counts.index) == {"page_view", "click", "purchase"}
    assert counts.sum() == 10_000


def test_user_aggregates(events):
    agg = user_aggregates(events)
    assert len(agg) == 500
    assert agg["events"].sum() == 10_000
    assert round(agg["revenue_usd"].sum(), 2) == round(events["revenue_usd"].sum(), 2)


def test_feature_matrix_shape(events):
    assert feature_matrix(events).shape == (500, 6)
