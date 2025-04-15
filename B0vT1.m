pm = MOLLI_params();
[p, df_t1] = MOLLI_sim_freq(pm);
%%
figure()
plot(df_t1(:,1), polyval(p,df_t1(:,1)),'r-', df_t1(:,1),df_t1(:,2),'go')
legend('Curve fit', 'Sampled points')
xlabel('Hz')
ylabel('Estimated T1 (ms)')