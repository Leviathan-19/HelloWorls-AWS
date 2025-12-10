import http from 'k6/http';
import { sleep } from 'k6';
import { check } from 'k6';

export const options = {
  stages: [
    { duration: '1m', target: 50 },   // ramp up a 50 VUs en 1m
    { duration: '2m', target: 200 },  // ramp up a 200 VUs en 2m
    { duration: '5m', target: 200 },  // mantener 200 VUs por 5m
    { duration: '2m', target: 0 },    // ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<2000'], // opcional: alerta si 95% > 2s
  },
};

const url = __ENV.TARGET || 'hello-lb-1729891670.us-east-1.elb.amazonaws.com';

export default function () {
  const r = http.get(url);
  check(r, { 'status 200': (r) => r.status === 200 });
  sleep(1);
}