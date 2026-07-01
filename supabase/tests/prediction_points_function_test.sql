begin;
select plan(5);

select is(public.calculate_prediction_points(2, 1, null, 2, 1, null, 'aa000000-0000-0000-0000-000000000001', 'aa000000-0000-0000-0000-000000000002'), 6, 'an exact decisive score awards 6 points');
select is(public.calculate_prediction_points(3, 0, null, 2, 1, null, 'aa000000-0000-0000-0000-000000000001', 'aa000000-0000-0000-0000-000000000002'), 3, 'the correct decisive winner awards 3 points');
select is(public.calculate_prediction_points(0, 1, null, 2, 1, null, 'aa000000-0000-0000-0000-000000000001', 'aa000000-0000-0000-0000-000000000002'), 0, 'the wrong decisive winner awards 0 points');
select is(public.calculate_prediction_points(1, 1, 'aa000000-0000-0000-0000-000000000001', 1, 1, 'aa000000-0000-0000-0000-000000000001', 'aa000000-0000-0000-0000-000000000001', 'aa000000-0000-0000-0000-000000000002'), 6, 'an exact draw and penalty winner awards 6 points');
select is(public.calculate_prediction_points(1, 1, 'aa000000-0000-0000-0000-000000000002', 1, 1, 'aa000000-0000-0000-0000-000000000001', 'aa000000-0000-0000-0000-000000000001', 'aa000000-0000-0000-0000-000000000002'), 0, 'the wrong penalty winner awards 0 points');

select * from finish();
rollback;
