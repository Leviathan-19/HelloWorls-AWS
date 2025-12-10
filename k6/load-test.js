import http from 'k6/http';
import { sleep } from 'k6';
import { check } from 'k6';

export const options = {
  stages: [
    { duration: '1m', target: 1000 },
    { duration: '1m', target: 5000 },
    { duration: '1m', target: 10000 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<2000'],
  },
};

const url = __ENV.TARGET || 'http://hello-lb-1849340736.us-east-1.elb.amazonaws.com/';

export default function () {
  const r = http.get(url);
  check(r, { 'status 200': (r) => r.status === 200 });
  //sleep(0.5);
}